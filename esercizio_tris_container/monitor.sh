#!/bin/bash

azzeramento_container(){
  clear
  echo "SPEGNIMENTO CONTAINER"
  for i in {1..9}; do
    docker rm -f "c${i}" > /dev/null 2>&1
    echo -n "█"
  done
  echo " 9/9"
}

win_combo=(
    "1 2 3"
    "4 5 6"
    "7 8 9"
    "1 4 7"
    "2 5 8"
    "3 6 9"
    "1 5 9"
    "3 5 7"
)

declare -a griglia
griglia=( "" "" "" "" "" "" "" "" "" "")

inizializzazione_griglia(){

  if docker ps -a --format "{{.Names}}" | grep -qE "^c[1-9]$"; then
    azzeramento_container
  fi

  echo "AVVIO CONTAINER"
  for i in {1..9}; do
    griglia[$i]=""
    docker run -d --name "c${i}" alpine sleep infinity > /dev/null 2>&1
    if [ $? -eq 1 ]; then
      return 1
    fi

    echo -n "█"
  done
  echo " 9/9"
  sleep 1
}

stampa_griglia(){

  clear

  local c1=${griglia[1]:-"1"} c2=${griglia[2]:-"2"} c3=${griglia[3]:-"3"}
  local c4=${griglia[4]:-"4"} c5=${griglia[5]:-"5"} c6=${griglia[6]:-"6"}
  local c7=${griglia[7]:-"7"} c8=${griglia[8]:-"8"} c9=${griglia[9]:-"9"}

  echo "| $c1 | $c2 | $c3 |"
  echo "|---|---|---|"
  echo "| $c4 | $c5 | $c6 |"
  echo "|---|---|---|"
  echo "| $c7 | $c8 | $c9 |"
}

check_mossa_valida(){

  local pos=$1
  if [[ $pos -ge 1 && $pos -le 9 && -z "${griglia[$pos]}" ]]; then
    return 0
  else
    return 1
  fi

}

esegui_mossa(){

  local pos=$1
  local giocatore=$2

  check_mossa_valida "$pos"
  if [[ $? -ne 0 ]]; then
    echo "Mossa non valida: posizione $pos"
    return 1
  fi

  griglia[$pos]=$giocatore
  docker exec "c${pos}" touch "/$giocatore" || { echo "Errore docker exec su c${pos}"; return 1; }

}

check_win(){

  local giocatore=$1

  for combo in "${win_combo[@]}"; do
    read -r a b c <<< "$combo"
    if [[ "${griglia[$a]}" == "$giocatore" && "${griglia[$b]}" == "$giocatore" && "${griglia[$c]}" == "$giocatore" ]]; then
      return 0
    fi
  done
  return 1

}

check_pareggio(){

  for i in {1..9}; do
    if [[ -z "${griglia[$i]}" ]]; then
      return 1
    fi
  done
  return 0

}

turno_giocatore(){

  local giocatore=$1
  local pos

  while true; do
    read -rp "Giocatore $giocatore, scegli una posizione (1-9): " pos
    esegui_mossa "$pos" "$giocatore" && break
  done

  stampa_griglia

  if check_win "$giocatore"; then
    echo "Giocatore $giocatore ha vinto!"
    return 0
  fi

  if check_pareggio; then
    echo "Pareggio!"
    return 0
  fi

  return 1

}

while true; do

  if ! inizializzazione_griglia; then
    echo "!!! ERRORE INIZIALIZZAZIONE -- CONTROLLARE CHE IL DOCKER DAEMON SIA AVVIATO !!!"
    break
  fi
  stampa_griglia

  giocatori=("X" "O")
  turno=0

  while true; do
    if [ $((turno % 2)) -eq 0 ]; then
      giocatore_corrente=${giocatori[0]}
    else
      giocatore_corrente=${giocatori[1]}
    fi
    ((turno++))
    trap '
    clear
    echo "ANNULLAMENTO GIOCO"
    azzeramento_container
    exit 1
    ' SIGINT
    turno_giocatore $giocatore_corrente && break
  done

  read -rp "Vuoi giocare ancora? (s/n): " scelta
  if [[ "$scelta" != "s" ]] ; then
    azzeramento_container && break
  fi

done