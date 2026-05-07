# script2.sh

Script Bash per la raccolta interattiva di stringhe, ordinamento alfabetico, rimozione duplicati tramite ciclo manuale e stampa in maiuscolo.

---

## Descrizione

Lo script raccoglie stringhe da input utente in un loop, le inserisce in un array e al termine:

1. Ordina l'array alfabeticamente tramite `sort`
2. Rimuove i duplicati confrontando elementi adiacenti con un ciclo `for`
3. Ricompatta l'array dopo gli `unset`
4. Stampa ogni elemento in maiuscolo

---

## Utilizzo

```bash
chmod +x script2.sh
./script2.sh
```

### Output atteso

```
inserisci stringa: banana
inserisci stringa: ananas
inserisci stringa: banana
inserisci stringa: 
ANANAS
BANANA
```

---

## Comandi principali

### `declare -a`

Dichiara esplicitamente la variabile come array indicizzato.

| Option | Descrizione |
|--------|-------------|
| `-a`   | Array indicizzato (indici numerici) |

---

### `[[ -z "$stringa" ]]`

Test condizionale usato per rilevare la stringa vuota e interrompere il loop.

| Flag | Descrizione |
|------|-------------|
| `-z` | `true` se la stringa ha lunghezza zero |

---

### `printf "%s\n"`

Stampa ogni elemento dell'array su una riga separata, necessario per passare input corretto a `sort`.

| Formato | Descrizione |
|---------|-------------|
| `%s`    | Argomento trattato come stringa |
| `\n`    | Newline dopo ogni elemento |

---

### `tr [:lower:] [:upper:]`

Converte le lettere minuscole in maiuscole sul flusso in arrivo.

| Argomento   | Descrizione |
|-------------|-------------|
| `[:lower:]` | Classe POSIX — lettere `a-z` |
| `[:upper:]` | Classe POSIX — lettere `A-Z` |

---

### `unset 'array_o[$i]'`

Elimina l'elemento all'indice `$i` dall'array.

> Lascia buchi negli indici numerici — richiede ricompattamento con `array_o=("${array_o[@]}")`.

---

## Struttura del codice

```
loop input
  └─ read stringa
       ├─ stringa vuota  →  break
       └─ array+=("$stringa")

array_o = sort(array) | tr minuscolo→MAIUSCOLO

for i in indici array_o
  └─ array_o[$i] == array_o[$i+1]  →  unset array_o[$i]

array_o = ricompattamento

for elemento in array_o
  └─ echo elemento
```

---

## Limitazioni note

- `unset` lascia buchi negli indici: il ricompattamento `array_o=("${array_o[@]}")` è necessario per iterare correttamente in seguito.
- Il confronto duplicati funziona solo su array già ordinato — elementi uguali non adiacenti non verrebbero rimossi.
- La sostituzione di comando `$(...)` usata per catturare l'output di `printf | sort | tr` esegue in una subshell separata.
