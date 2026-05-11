#!/bin/bash

barra_caricamento (){
  
  for (( i = 0; i < 60; i++ )); do
    echo -n "█"
    sleep 1
  done
  clear
}

immagine="ealen/echo-server"
nome_c="echo"

macchina="m1"

clear
echo "scarico immagine su entrambe le macchine"
vagrant ssh m1 -c "docker pull "$immagine > /dev/null 2>&1
vagrant ssh m2 -c "docker pull "$immagine > /dev/null 2>&1
clear

echo "avvio l'immagine sulla macchina "$macchina
vagrant ssh $macchina -c "docker run -d --name $nome_c $immagine" > /dev/null 2>&1

while true; do 
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
        break
    fi
    clear    
        
    echo "avvio l'immagine su $destinazione"  
    vagrant ssh $destinazione -c "docker run -d --name $nome_c $immagine" > /dev/null 2>&1
    clear
    echo "immagine $nome_c in esecuzione su $destinazione"  
    macchina=$destinazione
    
done