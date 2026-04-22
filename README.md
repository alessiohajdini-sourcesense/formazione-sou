ESERCIZIO CONFLITTO GIT





1. INIZIALIZZAZIONE DEL REPOSITORY

   git init ----->ho inizializzato git nella directory /home/vboxuser

2. PRIMO COMMIT SUL BRANCH MAIN
  
   ho quindi modificato il file testo.txt con vim con il seguente contenuto:
   prova prova prova1
   poi ho eseguito il commit:

   git add testo.txt
   git commit -m "primo"

3. CREAZIONE DEL BRANCH PIPPO

   git checkout -b pippo

4. MODIFICA DELLA STESSA RIGA SUL BRANCH PIPPO

   ho poi modificato il file testo.txt sempre con vim con il seguente contenuto:
   prova prova prova2
   poi ho eseguito il commit:

   git add testo.txt
   git commit -m "secondo"


5. TENTATIVO DI MERGE (genera il conflitto)

   git merge pippo

   Output atteso:
   Auto-merging testo.txt
   CONFLICT (content): Merge conflict in testo.txt
   Automatic merge failed; fix conflicts and then commit the result.

6. ISPEZIONE DEL CONFLITTO

   cat testo.txt

   Contenuto del file in stato di conflitto:

   <<<<<<< HEAD
   riga 1: modifica dal branch main
   =======
   riga 1: modifica dal branch pippo
   >>>>>>> pippo

   I marker significano:
   - <<<<<<< HEAD        → versione del branch corrente (main)
   - =======             → separatore
   - >>>>>>> pippo    → versione del branch in ingresso

   git status mostra il file come "both modified".

7. RISOLUZIONE MANUALE

   Aprire testo.txt, eliminare i marker e scegliere (o combinare) il contenuto:

   riga 1: versione finale dopo risoluzione manuale del conflitto

   Poi:

   git add testo.txt
   git commit -m "finale"

---

Perché Git NON risolve automaticamente questo conflitto:
Git esegue il merge automatico solo quando le modifiche riguardano righe diverse. Quando due branch modificano la stessa riga dello stesso file, Git non ha criteri per scegliere quale versione sia corretta: la decisione è semantica, non sintattica, e richiede intervento umano.
