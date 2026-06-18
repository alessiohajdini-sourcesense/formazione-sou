#!/bin/bash

declare -A cpu_somma
declare -A cpu_cont

while IFS= read -r riga; do
    server=$(echo "$riga" | awk '{print $1}')
    cpu=$(echo "$riga" | awk '{print $2}')

    cpu_somma[$server]=$(( ${cpu_somma[$server]} + cpu ))
    cpu_cont[$server]=$(( ${cpu_cont[$server]} + 1 ))
done < metriche.txt

for server in "${!cpu_somma[@]}"; do
  media=$(( cpu_somma[$server] / cpu_cont[$server] ))
  echo "$server media CPU: $media%"
done