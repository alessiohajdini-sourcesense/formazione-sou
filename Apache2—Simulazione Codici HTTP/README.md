# Apache2 — Simulazione Codici HTTP

Esercizio pratico su Apache2 per provocare e osservare diversi codici di risposta HTTP,
eseguito su una VM Vagrant con Ubuntu (Apache/2.4.18).

---

## Ambiente

- **OS:** Ubuntu (Vagrant VM, hostname: `vagrant@m1`)
- **Web server:** Apache/2.4.18
- **Tool di test:** `curl`
- **Log monitorato in tempo reale:** `sudo tail -f -n 1 /var/log/apache2/access.log`

---

## 1. Risposta 200 OK

Richiesta base al server senza alcuna configurazione aggiuntiva:

```bash
curl localhost
```

Il server risponde con il contenuto della pagina di default di Apache (`/var/www/html/index.html`).

Il log conferma la risposta:

```
::1 - - [13/May/2026:07:16:56 +0000] "GET / HTTP/1.1" 200 11576 "-" "curl/7.47.0"
```

---

## 2. Risposta 301 Moved Permanently

Redirect permanente verso un URL esterno configurato con la direttiva `Redirect`.

**Configurazione in `000-default.conf`:**

```apache
Redirect 301 / https://google.com
```

```bash
curl localhost
```

Il server risponde con la pagina HTML di redirect:

```html
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>301 Moved Permanently</title>
</head><body>
<h1>Moved Permanently</h1>
<p>The document has moved <a href="https://google.com">here</a>.</p>
<hr>
<address>Apache/2.4.18 (Ubuntu) Server at localhost Port 80</address>
</body></html>
```

Senza il flag `-L`, `curl` non segue il redirect e mostra la risposta grezza.
Con `-L` seguirebbe automaticamente l'header `Location: https://google.com`.

Il log mostra la transizione da 200 a 301 dopo la modifica della configurazione:

```
::1 - - [13/May/2026:07:29:44 +0000] "GET / HTTP/1.1" 200 11576 "-" "curl/7.47.0"
::1 - - [13/May/2026:07:30:47 +0000] "GET / HTTP/1.1" 301 500 "-" "curl/7.47.0"
```

---

## 3. Risposta 401 Unauthorized

Accesso a una directory protetta con autenticazione HTTP Basic.

### Creazione delle credenziali

```bash
htpasswd /etc/apache2/.htpasswd pippo
```

Il comando crea il file `.htpasswd` con l'utente `pippo` e la password inserita interattivamente in forma hash.

### Configurazione in `000-default.conf`

```apache
<Directory "/var/www/html/privato">
    AuthType Basic
    AuthName "Area Riservata"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Directory>
```

### Test con credenziali errate → 401

```bash
curl -u pippo:ciao localhost/privato
```

Il server risponde:

```html
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>401 Unauthorized</title>
</head><body>
<h1>Unauthorized</h1>
<p>This server could not verify that you
are authorized to access the document
requested. Either you supplied the wrong
credentials (e.g., bad password), or your
browser doesn't understand how to supply
the credentials required.</p>
<hr>
<address>Apache/2.4.18 (Ubuntu) Server at localhost Port 80</address>
</body></html>
```

Il log registra il tentativo fallito con il codice 401:

```
::1 - - [13/May/2026:07:16:56 +0000] "GET / HTTP/1.1" 200 11576 "-" "curl/7.47.0"
::1 - - [13/May/2026:07:19:37 +0000] "GET /html HTTP/1.1" 503 564 "-" "curl/7.47.0"
::1 - - [13/May/2026:07:20:23 +0000] "GET /ciao HTTP/1.1" 404 432 "-" "curl/7.47.0"
::1 - pippo [13/May/2026:07:21:09 +0000] "GET /privato HTTP/1.1" 401 668 "-" "curl/7.47.0"
```

### Test con credenziali corrette → 200

```bash
curl -u pippo:kali localhost/privato/
```

Il server restituisce il contenuto della directory (`PRIVATO`).

Il log conferma il 200 con l'utente autenticato:

```
::1 - pippo [13/May/2026:07:26:56 +0000] "GET /privato/ HTTP/1.1" 200 233 "-" "curl/7.47.0"
```

---

## 4. Risposta 404 Not Found

Richiesta verso un path che non esiste sul server:

```bash
curl localhost/ciao
```

Il server risponde:

```html
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL was not found on this server.</p>
<hr>
<address>Apache/2.4.18 (Ubuntu) Server at localhost Port 80</address>
</body></html>
```

Il log si aggiorna:

```
::1 - - [13/May/2026:07:16:56 +0000] "GET / HTTP/1.1" 200 11576 "-" "curl/7.47.0"
::1 - - [13/May/2026:07:19:37 +0000] "GET /html HTTP/1.1" 503 564 "-" "curl/7.47.0"
::1 - - [13/May/2026:07:20:23 +0000] "GET /ciao HTTP/1.1" 404 432 "-" "curl/7.47.0"
```

---

## 5. Risposta 503 Service Unavailable

Configurata tramite `mod_rewrite` nel VirtualHost per simulare una manutenzione su un path specifico.

Prima di usare `RewriteRule` è necessario abilitare il modulo:

```bash
sudo a2enmod rewrite
sudo systemctl reload apache2
```

**Configurazione aggiunta in `000-default.conf`:**

```apache
RewriteEngine On
RewriteRule ^/html$ - [R=503,L]
```

Il flag `[R=503,L]` forza la risposta 503 senza reindirizzare altrove. Il flag `L` (Last) dice ad Apache di fermarsi e non valutare altre regole.

```bash
curl localhost/html
```

Il server risponde:

```html
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>503 Service Unavailable</title>
</head><body>
<h1>Service Unavailable</h1>
<p>The server is temporarily unable to service your
request due to maintenance downtime or capacity
problems. Please try again later.</p>
<hr>
<address>Apache/2.4.18 (Ubuntu) Server at localhost Port 80</address>
</body></html>
```

Il log mostra la sequenza delle richieste:

```
::1 - - [13/May/2026:07:16:56 +0000] "GET / HTTP/1.1" 200 11576 "-" "curl/7.47.0"
::1 - - [13/May/2026:07:19:37 +0000] "GET /html HTTP/1.1" 503 564 "-" "curl/7.47.0"
```

---

## Riepilogo codici provocati

| Codice | Descrizione | Metodo usato |
|--------|-------------|--------------|
| 200 | OK | `curl localhost` — risposta normale |
| 301 | Moved Permanently | Direttiva `Redirect 301 / https://google.com` |
| 401 | Unauthorized | Basic Auth con `.htpasswd` — credenziali errate |
| 404 | Not Found | Path inesistente `curl localhost/ciao` |
| 503 | Service Unavailable | `RewriteRule ^/html$ - [R=503,L]` (richiede `a2enmod rewrite`) |

---

## Comandi utili

```bash
# Ricaricare Apache dopo modifiche alla config
sudo systemctl reload apache2

# Verificare la sintassi prima di ricaricare
sudo apache2ctl configtest

# Monitorare i log in tempo reale
sudo tail -f /var/log/apache2/access.log
sudo tail -f /var/log/apache2/error.log

# Vedere VirtualHost attivi e ordine di caricamento
apache2ctl -S
```
