# Esercizio: Filtrare un CSV con AWK

## Traccia

Scrivere un programma AWK che prende in input un file `.csv` e stampa il **terzo campo** solo se viene matchata la stringa `"banana"`.

---

## Soluzione 1 — AWK (principale)

```bash
#!/bin/bash

echo "inserisci il path del file: "
read nome_file
clear

awk -F, '/banana/ {print $3}' $nome_file
```

### Come funziona

- **`-F,`** — imposta la virgola come separatore di campo.
- **`/banana/`** — seleziona solo le righe che contengono la stringa `banana`.
- **`{print $3}`** — stampa il terzo campo delle righe selezionate.

---

## Soluzione 2 — `grep` + `sed`

```bash
#!/bin/bash

echo "inserisci il path del file: "
read nome_file
clear

grep 'banana' $nome_file | sed -n 's/^\([^,]*,\)\{2\}\([^,]*\).*/\2/p'
```

### Come funziona

1. **`grep 'banana' $nome_file`** — filtra solo le righe che contengono `banana`.
2. **`sed -n 's/^\([^,]*,\)\{2\}\([^,]*\).*/\2/p'`** — estrae il terzo campo:
   - `\([^,]*,\)\{2\}` — cattura e scarta i primi due campi (tutto fino alla seconda virgola).
   - `\([^,]*\)` — cattura il terzo campo.
   - `\2` — stampa solo il secondo gruppo di cattura.
   - `-n` + `/p` — stampa solo le righe che fanno match.

---

## Soluzione 3 — `grep` + `cut`

```bash
#!/bin/bash

echo "inserisci il path del file: "
read nome_file
clear

grep 'banana' $nome_file | cut -d',' -f3
```

### Come funziona

1. **`grep 'banana' $nome_file`** — filtra solo le righe che contengono `banana`.
2. **`cut -d',' -f3`** — estrae il terzo campo:
   - `-d','` — imposta la virgola come delimitatore.
   - `-f3` — seleziona il terzo campo.

Rispetto alla soluzione con `sed`, è più leggibile e diretta per estrarre un campo da un CSV.

---

## Esempio

Dato il file `pippo.csv`:

```
apple,banana,strawberry
pear,peach,lemon
banana,kiwi,orange
```

Le righe che contengono `banana` sono la **1** e la **3**. Il terzo campo di quelle righe è:

Output atteso:

```
strawberry
orange
```
