#!/bin/bash

declare -a array    # Dichiara un array chiamato "array"

# Ciclo infinito: continua a chiedere stringhe finché l'utente inserisce una riga vuota
while true; do
  echo "inserisci stringa: "
  read stringa

  [[ -z "$stringa" ]] && break    # Se la stringa è vuota, interrompe il ciclo while
  array+=("$stringa")
done

# Ordina alfabeticamente gli elementi dell'array
# printf stampa ogni elemento su una riga diversa
# sort ordina le righe
# Il risultato viene salvato nel nuovo array "array_o"
array_o=($(printf "%s\n" "${array[@]}" | sort | tr [:lower:] [:upper:]))   # trasformo le lettere minuscole in maiuscole

# Ciclo sugli indici dell'array ordinato
for i in "${!array_o[@]}"; do
  i_prox=$((i+1))

  if [[ ${array_o[$i_prox]} && ${array_o[$i]} == ${array_o[$i_prox]} ]]; then   # Controlla se l'elemento successivo esiste e se l'elemento corrente è uguale a quello successivo
      
      unset 'array_o[$i]'   # Se sono uguali, elimina l'elemento corrente
  fi
done

array_o=("${array_o[@]}")   # Ricompatta l'array dopo gli unset. Serve perché unset lascia "buchi" negli indici dell'array

# Stampo tutti gli elementi trasformati in maiuscolo dell'array ordinato e senza duplicati
for i in "${array_o[@]}"; do
    echo $i
done