#!/bin/bash

echo "inserisci il path del file: "
read nome_file
clear

grep 'banana' $nome_file | sed -n 's/^\([^,]*,\)\{2\}\([^,]*\).*/\2/p'