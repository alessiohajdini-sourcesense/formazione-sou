# Backup & Restore MariaDB con Ansible e AWX

Task di riferimento (Academy #6):

> - Creazione di un'istanza MariaDB su una VM e popolarla con dati di test
> - Esecuzione del backup del DB
> - Restore del backup su un'altra istanza dentro un'altra VM
> - Esecuzione query per verificare la consistenza dei dati
> - Orchestrare la procedura con Ansible e mettere le credenziali dell'utente DB in un Vault
> - Studiare lo strumento AWX per eseguire playbook Ansible e integrare quanto fatto in AWX

---

## Infrastruttura

Due VM VirtualBox gestite dal [Vagrantfile](Vagrantfile), entrambe con MariaDB installato in fase di provisioning (`apt install mariadb-server` + enable/start del servizio):

| VM (Vagrant) | Hostname | IP rete privata | Porta SSH forwardata | Ruolo |
|---|---|---|---|---|
| db1 | m1 | 192.168.56.104 | 2223 | istanza sorgente (backup) |
| db2 | m2 | 192.168.56.105 | 2224 | istanza destinazione (restore) |

```bash
vagrant up
```

Le VM si vedono tra loro sulla rete host-only `192.168.56.x`; dall'esterno (es. AWX) si raggiungono via port forwarding sull'IP del Mac.

---

## Fase 1 — Procedura manuale

Prima di automatizzare, l'intero flusso è stato eseguito a mano per capire ogni passaggio.

### 1.1 Creazione database e dati di test (su m1)

Il database `academy` è popolato con lo script `utenti_fittizi.sql`: crea la
tabella `utenti` e inserisce **20 account fittizi** (username, email, hash
SHA2-256 della password, nome, cognome, ruolo `admin`/`editor`/`user`, flag
attivo, data di registrazione).

```sql
CREATE DATABASE IF NOT EXISTS academy
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE academy;

CREATE TABLE utenti (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash CHAR(64) NOT NULL,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    ruolo ENUM('admin','editor','user') NOT NULL DEFAULT 'user',
    attivo TINYINT(1) NOT NULL DEFAULT 1,
    data_registrazione DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO utenti (username, email, password_hash, ...) VALUES
('mrossi', 'mario.rossi@example.com', SHA2('...', 256), 'Mario', 'Rossi', 'admin', 1, '2024-01-15 09:12:00'),
-- ... 20 righe totali
```

Caricamento dello script:

```bash
vagrant ssh db1
sudo mariadb < utenti_fittizi.sql
```

### 1.2 Backup (su m1)

```bash
mariadb-dump -u academy_user -p<password> --databases academy > /tmp/academy.sql
```

> Il flag `--databases` include nel dump anche `CREATE DATABASE` e `USE`,
> quindi il restore non richiede di creare il database a mano.

### 1.3 Trasferimento del dump su m2

```bash
scp /tmp/academy.sql vagrant@192.168.56.105:/tmp/
```

(richiede chiave SSH da m1 verso m2: `ssh-keygen` + `ssh-copy-id vagrant@192.168.56.105`)

### 1.4 Restore (su m2)

```bash
sudo mariadb < /tmp/academy.sql
```

> **Nota**: niente nome db nel comando — lo crea il dump stesso grazie a `--databases`.
> Con `mariadb academy < ...` il client proverebbe a connettersi a un db non ancora
> esistente → `ERROR 1049 Unknown database`.

### 1.5 Verifica consistenza (su entrambe)

```sql
USE academy;
SELECT COUNT(*) FROM utenti;                    -- atteso: 20
SELECT ruolo, COUNT(*) FROM utenti GROUP BY ruolo;
SELECT COUNT(*) FROM utenti WHERE attivo = 0;   -- atteso: 3
CHECKSUM TABLE utenti;
```

I risultati (conteggio righe, distribuzione ruoli e checksum) devono coincidere
tra m1 e m2.

---

## Fase 2 — Automazione con Ansible

### 2.1 Struttura del progetto

```
.
├── inventory.ini            # host m1/m2 con IP e utente
├── site.yml                 # playbook completo: backup + restore
├── backup.yml               # solo backup (playbook standalone)
├── restore.yml              # solo restore (playbook standalone)
├── group_vars/
│   └── all/
│       ├── vars.yml         # db_user, db_password (rimando al vault), db_name
│       └── vault.yml        # credenziali cifrate con ansible-vault
└── roles/
    ├── backup/tasks/main.yml
    └── restore/tasks/main.yml
```

### 2.2 Inventory

```ini
[prova]
m2 ansible_host=192.168.56.105 ansible_user=vagrant
m1 ansible_host=192.168.56.104 ansible_user=vagrant
```

### 2.3 Credenziali nel Vault

Le credenziali dell'utente DB non stanno mai in chiaro nel repository:

```bash
ansible-vault create group_vars/all/vault.yml
```

```yaml
# contenuto cifrato
db_usr: academy_user
db_passwd: <password>
```

`group_vars/all/vars.yml` fa da livello di indirezione (pattern standard):

```yaml
db_user: "{{ db_usr }}"
db_password: "{{ db_passwd }}"
db_name: academy
```

### 2.4 Ruolo `backup` (esegue su m1)

1. **dump**: `mariadb-dump --databases {{ db_name }} > /tmp/{{ db_name }}.sql`
2. **trasferimento** verso m2 via `scp` diretto sulla rete privata
   (`hostvars['m2'].private_ip`), con chiave SSH pre-condivisa tra le VM

Alternativa provata e documentata: `fetch` (m1 → controller) + `copy` (controller → m2),
che non richiede connettività tra le VM. `fetch` va usato con `flat: true`, altrimenti
crea l'albero `dest/hostname/percorso/` e il file diventa una directory.

### 2.5 Ruolo `restore` (esegue su m2)

```yaml
- name: restore database mariadb
  ansible.builtin.shell:
    cmd: "mariadb < /tmp/{{ db_name }}.sql"
  when: inventory_hostname == "m2"
```

### 2.6 Esecuzione

```bash
# flusso completo
ansible-playbook -i inventory.ini site.yml --ask-vault-pass

# oppure singole fasi
ansible-playbook -i inventory.ini backup.yml --ask-vault-pass
ansible-playbook -i inventory.ini restore.yml --ask-vault-pass
```

---

## Fase 3 — Integrazione con AWX

### 3.1 Installazione AWX su Kubernetes (kind)

AWX gira in un cluster [kind](https://kind.sigs.k8s.io/) locale. Tre file la governano:

**[kind-config.yml](kind-config.yml)** — cluster con la porta 30080 mappata sul Mac:

```bash
kind create cluster --config kind-config.yml
```

**[kustomization.yml](kustomization.yml)** — installa l'AWX Operator (v2.19.1) nel namespace `awx`:

```bash
kubectl apply -k .
```

> Nota: le Kustomization si applicano con `-k` sulla directory, **non** con `-f` sul file
> (con `-f` si ottiene `no matches for kind "Kustomization"`).

**[awx.yml](awx.yml)** — istanza AWX esposta come NodePort 30080:

```bash
kubectl apply -f awx.yml -n awx
```

Password admin generata dall'operator:

```bash
kubectl get secret awx-admin-password -n awx -o jsonpath='{.data.password}' | base64 -d
```

UI raggiungibile su `http://localhost:30080` (admin / password recuperata sopra).

### 3.2 Configurazione in AWX

1. **Project** → punta al repository Git; i playbook rilevabili sono quelli nella
   root del progetto (`site.yml`, `backup.yml`, `restore.yml`) — AWX mostra solo
   file che iniziano con un play (`hosts:`), non i task file dei ruoli.

2. **Inventory** → gli host vanno definiti con l'endpoint che **AWX** può raggiungere.
   AWX vive dentro kind e non vede la rete host-only di VirtualBox, quindi si passa
   dal port forwarding del Mac:

   ```yaml
   # host m1
   ansible_host: 192.168.3.87    # IP del Mac
   ansible_port: 2223
   ansible_user: vagrant
   private_ip: 192.168.56.104    # IP interno, per il traffico VM-to-VM

   # host m2
   ansible_host: 192.168.3.87
   ansible_port: 2224
   ansible_user: vagrant
   private_ip: 192.168.56.105
   ```

   `ansible_host` = "come AWX arriva alla VM"; `private_ip` = "come le VM si
   parlano tra loro" (usato dallo scp del backup).

3. **Credentials**:
   - *Machine* → chiave SSH per l'utente `vagrant`
   - *Vault* → la password del vault, così AWX decifra `group_vars/all/vault.yml`

4. **Job Templates** → uno per playbook (`site.yml`, `backup.yml`, `restore.yml`),
   ognuno con inventory, machine credential e vault credential agganciate.
   - Il campo **Limit** (equivalente di `--limit`) permette di restringere gli host
     al lancio senza toccare i playbook; con *Prompt on launch* viene chiesto a ogni run.
   - La spunta **Privilege Escalation** forza `--become` (ridondante qui: i playbook
     hanno già `become: true`).

5. **Esecuzione**: lanciare il template di `site.yml` esegue backup su m1 e
   restore su m2 nello stesso job.

> **Vincolo importante**: ogni job AWX gira in un pod effimero — il `/tmp` del
> controller non sopravvive tra un job e l'altro. Il flusso completo va quindi
> eseguito con `site.yml` in un unico job (oppure con il trasferimento diretto
> m1→m2 via scp, che non passa dal controller).

---

## Problemi incontrati e soluzioni

| Problema | Causa | Soluzione |
|---|---|---|
| `Can't initialize batch_readline` al restore | `fetch` senza `flat: true` crea una directory al posto del file | `flat: true` + bonifica del residuo con `file: state=absent` |
| `ERROR 1049 Unknown database` | `mariadb academy < dump` con dump fatto con `--databases` | togliere il nome db: `mariadb < dump` (lo crea il dump) |
| `no matches for kind "Kustomization"` | `kubectl apply -f` su una kustomization | usare `kubectl apply -k <directory>` |
| Task scp "inchiodato" | scp attende password/host-key in modo interattivo | chiave SSH tra le VM, `BatchMode=yes`, `StrictHostKeyChecking=accept-new`, `become: false` |
| AWX non raggiunge le VM | AWX (in kind) non vede la rete host-only 192.168.56.x | `ansible_host` = IP del Mac + porta forwardata; `private_ip` per il traffico tra VM |
