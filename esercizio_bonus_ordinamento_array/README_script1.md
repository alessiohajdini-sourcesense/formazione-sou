# script1.sh

Script Bash per la raccolta di stringhe su riga singola, con ordinamento, deduplicazione e stampa in maiuscolo tramite pipeline Unix.

---

## Descrizione

Lo script legge tutte le stringhe in una sola riga di input e le processa interamente attraverso una pipeline:

```
printf | tr | sort | uniq
```

Ogni comando riceve l'output del precedente tramite `|`, senza variabili intermedie né cicli espliciti.

---

## Utilizzo

```bash
chmod +x script1.sh
./script1.sh
```

### Output atteso

```
inserici la stringa:
banana ananas banana ciliegia
ANANAS
BANANA
CILIEGIA
```

---

## Comandi principali

### `read -a`

Legge una riga da stdin e la divide in token separati da spazio, salvandoli come elementi dell'array.

| Option | Descrizione |
|--------|-------------|
| `-a`   | Salva i token in un array invece che in una variabile scalare |

---

### `printf "%s\n"`

Stampa ogni elemento dell'array su una riga separata, necessario perché `sort` e `uniq` lavorano su righe.

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

### `uniq`

Rimuove le righe adiacenti duplicate dal flusso in arrivo.

> `uniq` opera solo su righe consecutive: richiede input già ordinato per eliminare tutti i duplicati, per questo `sort` viene prima nella pipeline.

---

## Struttura del codice

```
read -a pippo  ←  "banana ananas banana ciliegia"

printf "%s\n" ${pippo[@]}
  └─ tr [:lower:] [:upper:]
       └─ sort
            └─ uniq  →  output
```

---

## Limitazioni note

- `read -a` divide i token per spazio: stringhe con spazi interni verrebbero spezzate in elementi distinti.
- `tr` viene applicato **prima** di `sort`, quindi l'ordinamento lavora già su stringhe maiuscole.
