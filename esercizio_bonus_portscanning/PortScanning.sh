#!/bin/bash

while [ true ]; do    
    echo "inserisci indirizzo ip: "
    read ip
    
    if ping -c 1 -W 1 "$ip" &> /dev/null; then
        echo "L'IP risponde ed è valido"
        break
    else
        echo "!!!! IP non raggiungibile o formato errato !!!!"
    fi
done

while [ true ]; do
    
  while [ true ]; do
    echo "inserisci porta iniziale: "
    read p1
    
    if [[ "$p1" -ge 0 && "$p1" -le 65535 ]]; then
      echo "valora porta $p1 valido"
      break
    else
      echo "!!!! valore porta $p1 non valido !!!!"
    fi 
  done

  while [ true ]; do
    echo "inserisci porta finale: "
    read p2
    
    if [[ "$p2" -ge 0 && "$p2" -le 65535 ]]; then
      echo "valora porta $p2 valido"
      break
    else
      echo "!!!! valore porta $p2 non valido !!!!"
    fi 
  done

   if [[ "$p1" -lt "$p2" ]]; then
          break
      else
          echo "!!!! porta iniziale deve essere minore alla porta finale !!!!"
      fi

done

for (( i=$p1; i<=$p2; i++ )); do
  
  nc -v -w 1 $ip $i > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
      echo "LA PORTA $i E' APERTA"
    else
      echo "LA PORTA $i NON E' APERTA"
    fi
    
done












