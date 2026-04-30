# conta_servizi.sh

Script Bash per il conteggio dei servizi `systemd` suddivisi per stato: attivi, inattivi e not-found.

---

## Descrizione

Lo script interroga `systemctl` per ottenere l'elenco completo delle unità `.service` presenti sul sistema e, per ognuna, verifica lo stato tramite `systemctl status`. I risultati vengono raggruppati in base al codice di uscita restituito:

| Categoria  | Exit code `systemctl status` | Significato                         |
|------------|------------------------------|-------------------------------------|
| Attivi     | `0`                          | Servizio in esecuzione (active)     |
| Inattivi   | `3`                          | Servizio fermato (inactive/stopped) |
| Not-found  | `4`                          | Unità non trovata o in stato failed |

---

## Requisiti

- Sistema Linux con `systemd`
- Bash 4+
- Privilegi `sudo` (richiesti da `systemctl status` per alcune unità)

---

## Utilizzo

```bash
chmod +x conta_servizi.sh
sudo ./conta_servizi.sh
```

### Output atteso

```
I servizi attivi sono: 42
I servizi inattivi sono: 17
I servizi not-found sono: 3
```

---

## Struttura del codice

Le variabili `$a`, `$i` e `$nf` sono dichiarate e inizializzate a `0` nel corpo principale dello script, con scope globale esplicito.

La funzione `conta_servizi` riceve l'exit code come parametro `$1` e aggiorna il contatore corrispondente tramite `if/elif`:

```
loop sui servizi
  └─ systemctl status "$s"  →  exit code salvato in $stato
       └─ conta_servizi $stato
            ├─ $1 == 0  →  ((a++))
            ├─ $1 == 3  →  ((i++))
            └─ $1 == 4  →  ((nf++))
```

Il loop `for` itera sui servizi nel corpo principale, separando la logica di iterazione dalla logica di conteggio gestita dalla funzione.

---

## Limitazioni note

- L'iterazione avviene su tutte le unità `.service` visibili: su sistemi con molti servizi l'esecuzione può risultare lenta.
- Il filtro `grep '.service'` usa un pattern non ancorato. Per un match preciso usare `grep '\.service '` oppure `grep '\.service$'`.
- I codici di uscita di `systemctl status` possono variare tra distribuzioni e versioni di systemd.
- Gli exit code diversi da `0`, `3` e `4` vengono silenziosamente ignorati.

---

## Autore

Alessio — DevOps Academy, Sourcesense SpA
