#!/bin/bash

echo "inserici la stringa:"
read -a pippo

# Stampa ogni elemento dell'array "pippo" su una riga separata,
# trasforma le lettere minuscole in maiuscole,
# ordina alfabeticamente le righe
# e rimuove eventuali duplicati.

printf "%s\n" ${pippo[@]} | tr [:lower:] [:upper:] | sort | uniq 


