declare -A mat

mat[0,0]=1; mat[0,1]=2; mat[0,2]=3
mat[1,0]=4; mat[1,1]=5; mat[1,2]=6
mat[2,0]=7; mat[2,1]=8; mat[2,2]=9

# accesso diretto
echo ${mat[1,2]}   # → 6

# stampa griglia
for ((i=0; i<3; i++)); do
  for ((j=0; j<3; j++)); do
    printf "%4d" "${mat[$i,$j]}"
  done
  echo
done