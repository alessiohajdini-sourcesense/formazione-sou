#!/bin/bash

barra_caricamento (){
  for (( i = 0; i < 55; i++ )); do
    echo -n "█"
    sleep 1
  done
  clear
}

immagine="ealen/echo-server"
nome_c="echo"

{
vagrant ssh m1 -c "docker pull "$immagine > /dev/null 2>&1
r1=$?
vagrant ssh m2 -c "docker pull "$immagine > /dev/null 2>&1
r2=$?
} &

until [[ $macchina == "m1" || $macchina == "m2" ]]; do
  echo "digita m1 o m2 per scegliere da che macchina iniziare"
  read macchina
  clear 
done
     

echo "avvio container sulla macchina "$macchina
vagrant ssh $macchina -c "docker run -d --name $nome_c $immagine" > /dev/null 2>&1

while [[ r1 -eq 0 && r2 -eq 0 ]]; do 
  barra_caricamento
  
    if [ "$macchina" == m1 ]; then
        sorgente="m1"
        destinazione="m2"
    else
        sorgente="m2"
        destinazione="m1"
    fi

    echo "migrazione da $sorgente a $destinazione"  
    vagrant ssh $sorgente -c "docker stop $nome_c &&  docker rm $nome_c" > /dev/null 2>&1
    if [ $? -ne 0  ]; then
      echo "!!! Qualcosa è andato storto !!!"
      break
    fi
    clear    
        
    echo "avvio il container su $destinazione"  
    vagrant ssh $destinazione -c "docker run -d --name $nome_c $immagine" > /dev/null 2>&1
    clear
    echo "container $nome_c in esecuzione su $destinazione"  
    macchina=$destinazione
    
done