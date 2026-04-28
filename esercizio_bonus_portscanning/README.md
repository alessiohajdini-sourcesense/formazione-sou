# Esercizio: Port Scanner con Bash e NetCat

## Traccia

Supponiamo di avere 2 VM sul proprio laptop che riescano a "vedersi" lato rete. Scrivere uno script Bash che si comporti come un **port scanner** per capire quali porte TCP sono in ascolto sull'altra VM.

Requisiti:
- Utilizzare un ciclo che invochi il comando `nc` (NetCat), **senza** usare la feature di port scanning nativa di `nc`.
- Supportare la customizzazione dell'IP/host target e del range di porte tramite input utente.
- Sanificare l'input fornito dall'utente.

---

## Soluzione

```bash
#!/bin/bash

while [ true ]; do    
    echo "inserisci indirizzo ip: "
    read ip
    
    if ping -c 1 -W 1 "$ip" &> /dev/null; then
        echo "L'IP risponde ed è valido"
        break
    else
        echo "!!!! IP non raggiungibile o formato errato !!!!"
    fi
done

while [ true ]; do
    
  while [ true ]; do
    echo "inserisci porta iniziale: "
    read p1
    
    if [[ "$p1" -ge 0 && "$p1" -le 65535 ]]; then
      echo "valora porta $p1 valido"
      break
    else
      echo "!!!! valore porta $p1 non valido !!!!"
    fi 
  done

  while [ true ]; do
    echo "inserisci porta finale: "
    read p2
    
    if [[ "$p2" -ge 0 && "$p2" -le 65535 ]]; then
      echo "valora porta $p2 valido"
      break
    else
      echo "!!!! valore porta $p2 non valido !!!!"
    fi 
  done

  if [[ "$p1" -lt "$p2" ]]; then
      break
  else
      echo "!!!! porta iniziale deve essere minore alla porta finale !!!!"
  fi

done

for (( i=$p1; i<=$p2; i++ )); do
  
  nc -v -w 1 $ip $i > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
      echo "LA PORTA $i E' APERTA"
    else
      echo "LA PORTA $i NON E' APERTA"
    fi
    
done
```

---

## Come funziona

### 1. Validazione dell'IP

```bash
while [ true ]; do
    ping -c 1 -W 1 "$ip" &> /dev/null
done
```

Il loop continua finché l'utente non inserisce un IP raggiungibile. La validazione avviene tramite `ping`:
- `-c 1` — (*count*) limita a 1 il numero di pacchetti ICMP inviati. Senza questa opzione `ping` girerebbe all'infinito.
- `-W 1` — (*wait*) imposta a 1 secondo il timeout massimo di attesa per la risposta. Evita che lo script si blocchi a lungo su IP non raggiungibili.
- `&> /dev/null` — reindirizza sia stdout (file descriptor 1) che stderr (file descriptor 2) verso `/dev/null`, scartando tutto l'output. Interessa solo il codice di uscita: `0` se l'host risponde, `1` se non raggiungibile.

Se `ping` ha successo (exit code 0), l'IP è valido e si esce dal loop con `break`.

### 2. Validazione del range di porte

```bash
if [[ "$p1" -ge 0 && "$p1" -le 65535 ]]; then
```

Per entrambe le porte (iniziale e finale) viene verificato che il valore rientri nel range valido TCP: **0–65535**. Il loop ripete la richiesta finché il valore non è valido.

### 3. Verifica della coerenza del range

```bash
if [[ "$p1" -lt "$p2" ]]; then
    break
else
    echo "!!!! porta iniziale deve essere minore alla porta finale !!!!"
fi
```

Un loop esterno ingloba i due loop delle porte e verifica che `p1` sia strettamente minore di `p2` tramite `-lt` (less than). Se il controllo fallisce, entrambe le porte vengono richieste nuovamente dall'inizio.

### 4. Scansione delle porte con nc

```bash
for (( i=$p1; i<=$p2; i++ )); do
  nc -v -w 1 $ip $i > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "LA PORTA $i E' APERTA"
  else
    echo "LA PORTA $i NON E' APERTA"
  fi
done
```

Il ciclo `for` itera su ogni porta nel range specificato e invoca `nc` per ciascuna:
- `-v` — modalità verbose.
- `-w 1` — timeout di 1 secondo per evitare attese su porte chiuse.
- `> /dev/null 2>&1` — reindirizza l'output in due passaggi: `> /dev/null` manda lo stdout (file descriptor 1) nel cestino, mentre `2>&1` reindirizza lo stderr (file descriptor 2) verso lo stesso destinatario di stdout, cioè `/dev/null`. Il risultato è che tutto l'output di `nc` viene scartato.
- `$?` — controlla il codice di uscita di `nc`: `0` significa connessione riuscita (porta aperta), qualsiasi altro valore significa porta chiusa.

Ogni porta produce sempre una riga di output esplicita, sia che sia aperta che chiusa.

---

## Esempio di output

```
LA PORTA 20 NON E' APERTA
LA PORTA 21 NON E' APERTA
LA PORTA 22 E' APERTA
LA PORTA 80 E' APERTA
LA PORTA 443 NON E' APERTA
```
