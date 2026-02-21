# Testplan Webserver met WordPress CMS

- Auteur(s) testplan: Ruben Van Bruyssel

## Test: Webserver met WordPress CMS

### Testprocedure:

1. Navigeer naar de `vagrant-g07` map.
2. Start de webserver op met `vagrant up web`.

### Verwacht resultaat:

- Het script moet de webserver installeren en geeft een succesmelding.
- Je kunt de website bezoeken op `http://192.168.151.60/`.

![alt text](img/web.png)
<!-- Voeg hier eventueel een screenshot van het verwachte resultaat in. -->

---

## Test: Instellen van WordPress CMS

### Testprocedure:

1. Surf naar `http://192.168.151.60/`.
2. Je krijgt nu de WordPress-installatiewizard te zien.
3. Volg de stappen van de installatiewizard:
   - Selecteer de gewenste taal en klik op "Doorgaan".
   - De databank gegevens zijn al ingevuld, klik op "Doorgaan".
   - Vul de sitegegevens in:
     - Site titel: Bijv. "SEP G07"
     - Gebruikersnaam: Kies een gebruikersnaam voor de admin-account.
     - Wachtwoord: Kies een sterk wachtwoord.
     - E-mailadres: Voer een geldig e-mailadres in.
   - Klik op "WordPress installeren".

### Verwacht resultaat:

- De WordPress-installatie wordt succesvol voltooid.
- Je wordt doorgestuurd naar het WordPress-dashboard.
- Je kunt de website bezoeken op `http://192.168.151.60/`.


## Test: Functionaliteit van WordPress

### Testprocedure:

1. Log in op het WordPress-dashboard via `http://192.168.151.60/wp-admin/`.
2. Voer de volgende acties uit:
   - Voeg een nieuwe pagina toe.
   - Publiceer een blogbericht.
   - Installeer een nieuw thema.
   - Voeg een plugin toe.


