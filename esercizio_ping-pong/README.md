# Ping-Pong Container

Progetto Vagrant a due nodi Linux con migrazione automatica di un container Docker ogni 60 secondi tra i nodi.

## Struttura del progetto

```
.
├── Vagrantfile
└── script1.sh
```

## Requisiti

- Vagrant
- VirtualBox
- Bash

## Infrastruttura

| Nodo | Hostname | IP             | CPU | RAM   |
|------|----------|----------------|-----|-------|
| m1   | m1       | 192.168.3.104  | 2   | 4096MB |
| m2   | m2       | 192.168.3.105  | 1   | 1024MB |

Entrambi i nodi vengono provisionati con Docker tramite shell provisioner.

## Avvio

```bash
vagrant up
bash script1.sh
```

All'avvio lo script chiede su quale nodo far partire il container:

```
digita m1 o m2 per scegliere da che macchina iniziare
```

## Comportamento

1. Lo script esegue il pull dell'immagine `ealen/echo-server` su entrambi i nodi in background
2. Avvia il container sul nodo scelto
3. Ogni 60 secondi stoppa e rimuove il container sul nodo attivo e lo riavvia sull'altro
4. La migrazione continua finché entrambi i nodi hanno l'immagine disponibile

```
m1 [echo-server] ──60s──> m2 [echo-server] ──60s──> m1 [echo-server] ...
```

## Implementazione

La migrazione è gestita da `script1.sh` tramite `vagrant ssh` con comandi Docker remoti. La barra di caricamento indica i 60 secondi di attesa prima di ogni migrazione.

La variabile `macchina` tiene traccia del nodo attivo e viene aggiornata ad ogni ciclo per determinare sorgente e destinazione della migrazione successiva.

## Note

- Il container gira su un solo nodo alla volta
- In caso di errore durante stop/rm il loop si interrompe con messaggio di errore
- L'output Docker viene soppresso (`/dev/null`) per una visualizzazione pulita
