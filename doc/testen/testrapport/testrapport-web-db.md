# Testrapport

- Uitvoerder(s) test: Ruben Van Bruyssel
- Uitgevoerd op: 03/09/2025
- Github commit: <!-- Git commit hash. -->

## Test: wordpress installeren

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

Verkregen resultaat:
De server is correct geconfigureerd en de installer is te zien:

![alt text](../../img/taal.png)

Er kan een account aangemaakt worden:

![alt text](../../img/acc.png)

De installatie is succesvol:

![alt text](../../img/succes.png)

De loginpagina is zichtbaar en de login werkt:

![alt text](../../img/loginwp.png)

Het dashboard is zichtbaar en de website is toegankelijk:

![alt text](../../img/site.png)

## Test: Functionaliteit van WordPress

### Testprocedure:

1. Log in op het WordPress-dashboard via `http://192.168.151.60/wp-admin/`.
2. Voer de volgende acties uit:
   - Voeg een nieuwe pagina toe.
   - Publiceer een blogbericht.
   - Installeer een nieuw thema.
   - Voeg een plugin toe.

Verkregen resultaat:

De pagina is aangemaakt en gepubliceerd:
![alt text](../../img/pagina.png)

Het blogbericht is gepubliceerd:
![alt text](../../img/post.png)

Het thema is geïnstalleerd en geactiveerd:
![alt text](../../img/thema.png)

De plugin is geïnstalleerd en geactiveerd:
![alt text](../../img/plugin.png)

De plugin is zichtbaar in de pluginlijst:
![alt text](../../img/plugin2.png)

<!-- Voeg hier eventueel een screenshot van het verkregen resultaat in. -->

Test geslaagd:

- [x] Ja
- [ ] Nee
