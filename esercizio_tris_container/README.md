# Tris con Docker Container

Un gioco del Tris in Bash che usa container Docker come celle della griglia.

## Idea

Ogni cella della griglia 3×3 è rappresentata da un container Docker Alpine (`c1`–`c9`). Quando un giocatore occupa una cella, lo script esegue `docker exec` per creare un file `/X` o `/O` all'interno del container corrispondente, rendendo lo stato della partita visibile anche dall'esterno tramite Docker.

```
| 1 | 2 | 3 |
|---|---|---|
| 4 | 5 | 6 |
|---|---|---|
| 7 | 8 | 9 |
```

## Prerequisiti

- Docker in esecuzione
- Bash

## Utilizzo

```bash
chmod +x monitor.sh
./monitor.sh
```

Lo script:
1. Avvia 9 container Alpine (`c1`–`c9`) in background
2. Alterna i turni tra il giocatore **X** e il giocatore **O**
3. Controlla vittoria e pareggio dopo ogni mossa
4. Al termine chiede se giocare di nuovo; in caso contrario rimuove tutti i container
5. In caso di `Ctrl+C` gestisce il segnale SIGINT, rimuove i container e termina

## Combinazioni vincenti

Righe: `1-2-3`, `4-5-6`, `7-8-9`  
Colonne: `1-4-7`, `2-5-8`, `3-6-9`  
Diagonali: `1-5-9`, `3-5-7`

## Funzioni principali

| Funzione | Descrizione |
|---|---|
| `inizializzazione_griglia` | Avvia i 9 container, azzera la griglia; ritorna 1 in caso di errore |
| `stampa_griglia` | Pulisce lo schermo e mostra la griglia (celle libere mostrano il numero 1-9) |
| `check_mossa_valida` | Verifica che la posizione sia nel range 1-9 e che la cella sia libera |
| `esegui_mossa` | Valida la mossa, aggiorna la griglia e crea il file `/$giocatore` nel container |
| `turno_giocatore` | Gestisce il turno: legge input, esegue la mossa, controlla vittoria e pareggio |
| `check_win` | Controlla se un giocatore ha completato una delle 8 combinazioni vincenti |
| `check_pareggio` | Controlla se tutte le 9 celle sono occupate (pareggio) |
| `azzeramento_container` | Rimuove forzatamente tutti i container `c1`–`c9` con progress bar |
