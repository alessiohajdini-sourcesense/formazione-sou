#!/bin/bash

#Dichiaro le varibili dei contatori
a=0
i=0
nf=0

#Funzione che conta i servizi attivi, inattivi e not-found 
conta_servizi(){    
    if [ $1 -eq 0 ]; then
      ((a++))
    elif [ $1 -eq 3 ]; then
      ((i++))
    elif [ $1 -eq 4 ]; then
      ((nf++))    
    fi
}

#Ciclo for dove faccio scorrere "s" nella lista dei servizi disponibili 
for s in $(systemctl list-units --all --no-legend | grep '.service' | awk '{print $1}'); do
  
  sudo systemctl status "$s" > /dev/null 2>&1     #comando per verificare lo stato dell servizio attualmete in "s"
  stato=$?    #assegno alla varibile "stato" l'exit code dell'ultimo comando eseguito
  conta_servizi $stato    #richiamo la funzione che conta i servizi passando come argomento la variabile "stato"
    
done

echo "I servizi attivi sono: $a"    #stampo a video il numero dei servizi attivi
echo "I servizi inattivi sono: $i"    #stampo a video il numero dei servizi inattivi
echo "I servizi not-found sono: $nf"    #stampo a video il numero dei servizi not-found