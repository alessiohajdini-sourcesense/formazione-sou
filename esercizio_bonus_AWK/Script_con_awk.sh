#!/bin/bash

echo "inserisci il path del file: "
read nome_file
clear


awk -F, '/banana/ {print $3}' $nome_file
