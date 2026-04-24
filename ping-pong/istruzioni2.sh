#!/bin/bash

immagine="ealen/echo-server"
nome_c="echo"
pausa=60

macchina="m1"

echo "scarico immagine su entrambe le macchine"
vagrant ssh m1 -c "docker pull "$immagine
vagrant ssh m2 -c "docker pull "$immagine

echo "avvio l'immagine sulla macchina "$macchina
vagrant ssh $macchina -c "docker run -d --name $nome_c -p 80:80 $immagine"

while true; do 
    sleep $pausa 
  
    if [ "$macchina" == m1 ]; then
        sorgente="m1"
        destinazione="m2"
    else
        sorgente="m2"
        destinazione="m1"
    fi
 
    echo "migrazione da $sorgente a $destinazione"  
    vagrant ssh $sorgente -c "
        docker stop $nome_c &&
        docker rm $nome_c"
        
    echo "avvio l'immagine su $destinazione"  
    vagrant ssh $destinazione -c "docker run -d --name $nome_c -p 80:80 $immagine"

    echo "immagine $nome_c in esecuzione su $destinazione"  
    macchina=$destinazione

done
    

