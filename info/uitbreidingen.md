# Uitbreidingen

In deze paragraaf worden uitbreidingen voor de basisomgeving omschreven. Hier kan je als team uit 'cherry picken': wat van deze zaken wil je implementeren? Bespreek met het team en overleg met de begeleider.

## NAT port forwarding

- Breid de NAT-configuratie (zie [basisopdracht](./basis.md)) uit met port forwarding: externe vragen op poort 80 worden afgeleverd aan de reverse proxy in DMZ. 
  Als extern IP-adres werk je niet met DHCP, maar met een statisch IP 172.22.200.**X**/16, waarbij **X** staat voor jullie groepsnummer (zie iteratie 2).
- Dit IP-adres resolved naar sepgroup**0X**.hogent.be (zonder leading zero als je groepsnummer groter is dan 9). Test door te surfen vanuit het klasnetwerk: is je website bereikbaar op https://sepgroup0X.hogent.be?

## Redundante router

- Ontdubbel je router: werk een redundante (passive) router uit die een kabelbreuk naar de switch, een kabelbreuk naar de ISP, of een falen van de eerste router, kan opvangen.
  Let wel: dit opzetten is enkel mogelijk vanaf iteratie 2!
  Als extern IP-adres werk je niet met DHCP, maar met een statisch IP (zie NAT port forwarding). De tweede router ken je 172.22.200.**10X**/16 toe, waarbij **X** staat voor jullie groepsnummer. FHRP configureer je enkel in jouw netwerk, niet aan de ISP-side.
- In een testplan test je ook de drie verschillende scenario's.
- Beide routers worden geconfigureerd vanaf de TFTP-server.

## Trunk naar bridged (TFTP) VM

- Een aparte server voor TFTP is misschien overkill: deze wordt immers enkel gebruikt om éénmalig de netwerkapparatuur in te stellen. Merge de configuratie van de TFTP-server met één van de Linux-servers die je extra opstelt - en beperk dit tot één extra VM.
- De twee services zijn weliswaar op dezelfde VM actief, maar worden op IP-adressen uit verschillende VLANs aangeboden. Scheid beide netwerken door het éne op een native interface aan te sluiten (geen VLAN tags), en het andere via een VLAN-tag toegang te geven tot de gewenste VLAN.
- Pas de switch aan zodat de VLANs toegelaten worden (native en tagged).
- Let wel: initieel wordt de TFTP-server nog steeds gebruikt om de netwerktoestellen te configureren!
- Beperk de toegang voor TFTP tot het IP-adres, gebruikt in de Management VLAN. Beperk de toegang tot de andere service tot het IP-adres, gebruikt in de VLAN 'Interne servers'.

## Intern IPv6

- Bereid jouw netwerk voor zodat het reeds (intern) dual stack werkt: zowel IPv4 als IPv6 werken in het eigen netwerk.
- IPv6 routing wordt enabled voor elke VLAN (behalve Management).
- Zowel DHCP als (interne) DNS worden uitgebreid met IPv6
- Verkeer tussen de eigen servers gaat bij voorkeur over IPv6 (werk dus de servers bij).

## CA installeren en certificaten uitrollen op Windows

- Rol een Certificate Authority (CA) uit op een Windows Server. Dit kan door de bestaande Domain Controller van het domain te gebruiken of door een afzonderlijke, nieuwe, Windows server machine toe te voegen. Je gebruikt hiervoor best de Active Directory Certificate Services feature.
- Genereer een webserver certificaat om een webserver naar keuze te laten werken met HTTPS (i.p.v. HTTP/poort 80).
- Distribueer het CA-certificaat naar client toestellen via een GPO.

## Redundante Windows server set-up

- Zorg voor een redundante Windows server set-up zodanig dat alle functionaliteit van het domain gegarandeerd blijft wanneer de DC onbeschikbaar zou worden.

## Werken met een Trust

- Maak een extra Domein Controller aan binnen een ander Active Directory-domein.
- Zorg ervoor dat een gebruiker uit het ene domein kan inloggen op een toestel in het andere domein en daar toegang heeft tot 
bepaalde bronnen. Toon aan dat er ook bronnen zijn waar deze gebruikers geen toegang tot hebben

## Uitgebreide GPO's

- Maak een extra groep aan waarbij volgende beperkingen worden opgelegd aan de gebruikers die hiervan deel uitmaken:
  * Geen toegang tot externe opslag (USB, externe harde schijven).
  * De achtergrond van het bureaublad is bij deze gebruikers egaal van kleur en onaanpasbaar.
  * Wijzigingen aan de taakbalk zijn niet toegestaan.
  * De folder 'Downloads' wordt automatisch gewist bij uitloggen.
  * Toegang tot Command Prompt, Powershell, en de Windows Register-editor is geblokkeerd.

## Matrix.org linux server

- Installeer [Synapse](https://matrix.org/docs/projects/server/synapse). Dit is een server voor het matrix.org protocol dat in de open source community steeds meer IRC en andere chatsystemen vervangt. Je kan er makkelijk bots op programmeren en bridges installeren naar andere chatplatformen zoals Discord, Messenger, ... . Daarnaast zijn chats default geëncrypteerd en onleesbaar voor admins.
- Matrix ondersteunt federatie (wat is dit?). Meestal is dit gewenst, maar hier hoef je dit niet op te zetten.
- Maak minstens 2 accounts en voer een geëncrypteerd gesprek.
- Maak een bash script op de webserver dat een bericht stuurt naar een matrix.org room als de webserver afsluit. Installeer dit script met een systemd unit en systemd timer.
- Installeer een bridge naar een extern chatplatform zoals Discord / IRC / Messenger / WhatsApp/ ... en zorg ervoor dat de Matrix.org accounts met gebruikers van dat extern platform kunnen communiceren en omgekeerd.

## Nextcloud linux server

- Installeer [Nextcloud](https://nextcloud.com/). Dit is een self hosted Google Suite / OneDrive kloon. Het biedt een platform aan om bestanden te delen of te synchroniseren (= Google Drive), kalenders aan te maken en te delen (= Google Calendar), contacten bij te houden en te beheren (Google Contacts) en nog veel meer. Dankzij Nextcloud heb je de functionaliteit gelijkaardig aan Google Suite of OneDrive, maar blijf je baas over je eigen data.
- Maak naast een admin account ook minstens 1 user account aan. Zorg ervoor dat een Windows 10/11 client (of Linux client) de Nextcloud server kan bereiken via https://nextcloud.l01-thematrix.internal dankzij de reverse proxy.
- Installeer op de client de Nextcloud software voor clients en zorg ervoor dat je bestanden kan synchroniseren met de server en/of andere clients.
- Maak een kalender aan en zorg ervoor dat je deze kan importeren/synchroniseren met Thunderbird op een client.
- Installeer een plugin om forms te maken en deel een link naar form met iemand anders zodat die de form kan invullen.

## JellyFin linux server

- Installeer [JellyFin](https://jellyfin.org/). Dit is een tool die je kan gebruiken om eigen media te beheren en raadplegen. In een bedrijfscontext kunnen we JellyFin gebruiken om enerzijds branding-gerelateerd bedrijfsmedia te gaan bijhouden (~ promo-filmpjes, interne trainingsvideo's, opnames van workshops of info-sessies, ...), maar ook om foto's en video's in verband met bedrijfsuitstappen of evenementen te gaan opslaan.
- Voorzie een logische en overzichtelijke mappenstructuur voor de hierboven vermeldde doeleinden.
- Voorzie een admin account dat kan gebruikt worden om in te loggen. Zorg ervoor dat een Windows 10/11 client (of Linux client) de JellyFin server kan bereiken via https://jellyfin.l01-thematrix.internal dankzij de reverse proxy.
- Zorg ervoor dat énkel deze eindgebruikers binnen de employees-VLAN toegang hebben tot de webinterface!
- Zorg ervoor dat er enkele foto's en video's automatisch worden geprovisioned bij het opzetten van het netwerk.
- Hou het professioneel - voorzie relevante en/of informatieve bestanden.

## NetBox linux server

- Installeer [NetBox](https://netboxlabs.com/oss/netbox/). Dit is een tool die je kan gebruiken voor netwerkdocumentatie, en bevat onder andere mogelijkheden tot het documenteren van IP-adressen (IPAM), (sub)netwerken en meer. 
- NetBox maakt gebruik van een PostgreSQL databank. Integreer dit in jouw bestaande databank indien je gebruik maakt van PostgreSQL binnen jouw opstelling, of zet op deze server een lokale PostgreSQL-databank op.
- Maak binnen NetBox een overzicht van het netwerk dat je hebt opgesteld voor dit projectwerk. Zorg ervoor dat de volgende componenten van het netwerk gedocumenteerd en zichtbaar zijn:
  - Overzicht van verschillende devices (~ VM's) binnen het netwerk
  - Overzicht van de gebruikte IP-adressen, de verschillende IP-ranges alsook de VLAN's
  - Voorzie elk device met een gepaste naam en rol, en label deze bovendien ook met het correcte besturingsysteem en bijhorende versie
  - Optioneel: maak gebruik van server racks om de VM's fysiek te emuleren en verbinden met elkaar
- Zorg ervoor dat deze documentatie automatisch geprovisioned wordt bij het opzetten van jouw netwerk. 
- Zorg ervoor dat een Windows 10/11 client (of Linux client) de NetBox server kan bereiken via https://netbox.l01-thematrix.internal dankzij de reverse proxy.
- Voorzie een admin account dat kan gebruikt worden om in te loggen en de netwerkdocumentatie te raadplegen. Zorg ervoor dat er na inloggen een overzichtelijk dashboard wordt aangeboden - met behulp van dit dashboard kan de gebruiker eenvoudig navigeren naar de bovenstaande componenten.

## Extra website

- Implementeer een tweede website naar keuze op de webserver. Zorg ervoor dat je naar deze website kan surfen via https://zelfgekozennaam.l01-thematrix.internal dankzij de reverse proxy. Werk je DNS-server bij zodat ook deze nieuwe URL gekend is.
- Implementeer load balancing voor deze website. Veel reverse proxies hebben hiervoor build-in support. Je zal wel de website (en eventueel databank) redundant moeten opzetten en ontdubbelen op een extra linux server.
- Host deze server op dezelfde webserver VM (zie [basisopdracht](./basis.md)). Beide webservers worden weliswaar gehost op hetzelfde IP-adres, maar worden op basis van URL gescheiden.
- Indien je met Apache werkt, kan deze scheiding door het opzetten van [vhosts](https://httpd.apache.org/docs/2.4/vhosts/).
- Indien je met Nginx werkt, kan deze scheiding door het opzetten van [server blocks](https://nginx.org/en/docs/http/server_names.html).

## Reverse proxy hardening

- Wat moeilijker dan het verbergen van de versie van de reverse proxy, is het verbergen van het type / gebruikte software pakket. Zoek uit hoe nmap geen of het verkeerde type reverse proxy weergeeft.

## IoT hardware server

- Implementeer één van jouw VMs op een fysiek IoT device, zoals
  - een RaspBerry Pi
  - een PcEngines ALIX (legacy)
  - een device in overleg met de lectoren
- Het IoT device kan je installeren met een default install procedure naar keuze
- Jouw configuratie-script logt in met ssh op dit toestel, en voert (automatisch) alle verdere configuraties uit (net zoals je zou doen met een VM).

## Database High Availability

Zet een database op met high availability als belangrijke requirement. Dat betekent concreet:

- De database is opgezet als een **cluster** met meerdere nodes (bv. Galera Cluster voor MariaDB of MySQL)
- Een **load balancer** verdeelt queries over de verschillende nodes van de cluster
- **Failover**: wanneer een van de nodes uitvalt, wordt het werk overgenomen door de andere node(s)
- Voeg voldoende schijven toe aan de nodes zodat je een **RAID-5** partitie kan opzetten voor de data-directory (bv. `/var/lib/mysql`).

Zie [practice: raid](https://hogenttin.github.io/linux-training-hogent/opslinux/storage_raid/#practice-raid) in de OpsLinux Syllabus en [deze labo-opstelling](https://github.com/HoGentTIN/linux-training-labs/tree/main/raid) voor een voorbeeld.
