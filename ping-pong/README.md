# Vagrant Container Migration – Ping Pong

Progetto Vagrant a due nodi Linux con Docker. Un container `echo-server` migra automaticamente da un nodo all'altro ogni 60 secondi.

---

## Prerequisiti

- [Vagrant](https://www.vagrantup.com/) ≥ 2.x
- [VirtualBox](https://www.virtualbox.org/) ≥ 6.x
- Bash (Linux/macOS o WSL su Windows)

---

## Struttura del progetto

```
.
├── Vagrantfile          # Definizione delle due VM (m1, m2)
└── istruzioni2.sh       # Script di migrazione automatica del container
```

---

## Infrastruttura

Il `Vagrantfile` crea due macchine virtuali Ubuntu con Docker preinstallato:

| Nodo | IP             | Risorse         |
|------|----------------|-----------------|
| m1   | 192.168.1.2    | 1 vCPU, 1024 MB |
| m2   | 192.168.1.3    | 1 vCPU, 1024 MB |

Le due VM comunicano tramite una rete privata (`private_network`).

---

## Avvio

### 1. Avviare le VM

```bash
vagrant up
```

### 2. Eseguire lo script di migrazione

```bash
bash istruzioni2.sh
```

Lo script:
1. Scarica l'immagine `ealen/echo-server` su entrambe le VM
2. Avvia il container su `m1`
3. Ogni 60 secondi, ferma il container sul nodo attivo e lo riavvia sull'altro

---

## Funzionamento

```
t=0s    → container avviato su m1
t=60s   → migrazione: m1 → m2
t=120s  → migrazione: m2 → m1
t=180s  → migrazione: m1 → m2
...
```

Il container espone un echo server HTTP raggiungibile sull'IP del nodo attivo.

---

## Comandi utili

```bash
# Stato delle VM
vagrant status

# Accesso a una VM
vagrant ssh m1
vagrant ssh m2

# Verifica container attivo su m1
vagrant ssh m1 -c "docker ps"

# Fermare e distruggere le VM
vagrant halt
vagrant destroy -f
```


