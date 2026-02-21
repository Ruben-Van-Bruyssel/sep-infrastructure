# Informatie ivm de opdracht

Deze directory bevat alle informatie in verband met de opdracht en praktische organisatie van het opleidingsonderdeel. De inhoud van deze directory wordt niet gewijzigd door de teamleden, enkel door de begeleiders (bv. voor het publiceren van errata).

## Overzicht

- [instructies.md](./instructies.md): Instructies voor het opstarten van het project, het gebruik van deze repository, enz.
- [studiewijzer.md](./studiewijzer.md): Studiewijzer voor het opleidingsonderdeel.
- [basis.md](./basis.md): Basisopdracht voor het project.
- [uitbreidingen.md](./uitbreidingen.md): Mogelijk uitbreidingen op de basisopdracht.

De [basisopdracht](./basis.md) moet door elk team volledig uitgevoerd en opgeleverd worden. Dit is een *nodige* maar nog *niet voldoende* voorwaarde om te slagen voor dit opleidingsonderdeel. Daarnaast kiezen jullie met jullie team ook een aantal [uitbreidingen](./uitbreidingen.md).

## Inleiding

Met dit project probeer je aan te tonen dat je in staat bent om met je team complexe ICT-infrastructuur geautomatiseerd kan opzetten en kan laten functioneren. Doel is om een volledig functioneel netwerk op te zetten met alle typische services: DNS, centraal gebruikersbeheer, DHCP, ...

Het is aan het team om te beslissen wie welke taken op zich zal nemen om die uit te werken, te testen en op te leveren. Elk teamlid draagt de eindverantwoordelijkheid voor minstens één deeltaak/component van het netwerk en beschrijft dit in haar/zijn logboek.

Jullie zullen merken dat jullie bij de meeste opdrachten van elkaar afhangen. Maak dus duidelijke afspraken die voor iedereen toegankelijk zijn via de technische documentatie van het project. Streef ernaar om diegenen die van jou afhangen zo goed mogelijk te helpen en hun werk zo vlot mogelijk te maken. Dat kan bestaan uit het ter beschikking stellen van een testomgeving voor de componenten onder jouw verantwoordelijkheid, hulp bij het gebruik ervan, of het vereenvoudigen van het gebruik door automatisering.


## Deelopdrachten

Lees de opgave grondig en doe zo goed mogelijk wat gevraagd wordt. Let er op dat bij verschillende taken addertjes onder het gras zitten, of dat ze bewust vaag geformuleerd zijn. Waar er geen expliciete keuze is opgelegd, kan het team zelf beslissen in samenspraak met de begeleiders. De opgave kan in de loop van het semester, naargelang de omstandigheden, nog bijgestuurd worden. De begeleiders kunnen bijkomende requirements opleggen of desgevallend de scope beperken. Het team kan zelf ook initiatief nemen om (telkens in samenspraak met de begeleiders) extra's te implementeren.

### Situatie

Jullie werken bij een groot softwarebedrijf. Dit bedrijf gaat een nieuwe vestiging openen op een andere locatie. Jullie team is aangesteld door de directie om de infrastructuur van de nieuwe vestiging op te zetten.

Kies gerust zelf een naam voor de vestiging, een logo/kleurenpalet mag je ook maken indien gewenst. Je kan deze gebruiken tijdens de opdrachten om er een eigen persoonlijk accent aan te geven.

### Basisopdracht

In [basis.md](./basis.md) wordt een basisomgeving omschreven. Dit is een baseline die je moet afwerken, en waar alle andere diensten in de vestiging gebruik van zullen maken. Deze omgeving moet zo geautomatiseerd mogelijk worden opgesteld, zodat je deze snel van scratch kan opzetten.

Er wordt verwacht dat de automatisatie van deze basisomgeving wordt afgewerkt en opgeleverd tegen week 7.

### Uitbreidingen

Let op: enkel het opzetten van de basisomgeving is **niet voldoende** om te slagen. Er is een lijst van mogelijke uitbreidingen beschikbaar in [uitbreidingen.md](./uitbreidingen.md) voor de basisomgeving. Minstens twee uitbreidingen zijn het minimum om het project als voldoende te kunnen beschouwen. Werk je als team meer uitdagingen af, dan kan je ook meer scoren in dit vak.

## Verwacht resultaat

We verwachten een **werkende basisopstelling** met **minstens 2 uitbreidingen** die binnen een bepaald tijdsinterval (bv. 2 uur) *from scratch* kan opgezet worden dankzij automatisatie.

Daarnaast verwachten we op deze GitHub repo het volgende:

- In de `src/`-directory is alle broncode aanwezig die nodig is om de omgeving op te zetten:

    - Broncode van scripts, geautomatiseerde tests, ...

    - PacketTracer-bestanden;

    - ...

- Documentatie in `doc/`:

    - Algemeen **netwerkschema** en **IP-adrestabel**;

    - Algemene **afspraken** binnen het team ivm communicatie, gebruik tools (onderling en met begeleiders):

        - Werkwijze gebruik versiebeheer (bv. branching of trunk-based development)
        - Kanban-bord en tijdregistratie
        - Voorbereiden opvolgingsgesprekken
        - ...

    - Duidelijke **directorystructuur** per deeltaak, met voor elke deeltaak de hieronder opgesomde documenten

    - **Technische documentatie** zoals

        - Neerslag van **opzoekwerk** ter voorbereiding (met bronvermeldingen!);
        - Dependencies en nodige software, systeemconfiguratie;
        - **Procedurehandleiding** voor het opzetten van de infrastructuur (geen copy/paste van broncode!);
        - **Cheat-sheets** en **checklists** voor vaak voorkomende taken en troubleshooting;

    - **Lastenboek** voor elke deeltaak (zie template [lastenboek.md](../doc/templates/lastenboek.md)):

        - specificaties en requirements;
        - verantwoordelijke voor realisatie, verantwoordelijke voor testen;
        - tijdschatting voor realisatie (in manuur);
        - na realisatie: werkelijk tijdgebruik aanvullen en een verklaring voor het afwijken van de schatting.

    - **Testplan** voor elke deeltaak (zie template [testplan.md](../doc/templates/testplan.md)): Een testplan is een **exacte** procedure van de handelingen die je moet uitvoeren om aan te tonen dat de opdracht volledig volbracht is en dat aan alle specificaties voldaan is. Een teamlid moet aan de hand van deze procedure in staat zijn om de tests uit te voeren en erover te rapporteren (zie testrapport). Geef bij elke stap het verwachte resultaat en hoe je kan verifiëren of dat resultaat ook behaald is.

        - Stel dit op terwijl je bezig bent met het opzetten van de omgeving!
        - Elke instelling die je maakt moet terug te vinden zijn in het testplan.
        - Testplannen vormen het draaiboek voor het geven van een demo bij de oplevering van deze deeltaak!

    - **Testrapport(en)** voor elke deeltaak (zie template [testrapport.md](../doc/templates/testrapport.md)): Een testrapport is het verslag van de uitvoering van het testplan door een teamlid. Dit moet iemand **anders** zijn dan de auteur van het testplan! Deze noteert bij elke stap in het testplan of het bekomen resultaat overeenstemt met wat verwacht werd. Indien niet, dan is het belangrijk om gedetailleerd op te geven wat er misloopt, wat het effectieve resultaat was, welke foutboodschappen gegenereerd werden, ... De tester kan meteen een Github issue aanmaken en er vanuit het testrapport naar verwijzen. Wanneer het probleem opgelost werd, wordt een nieuwe test uitgevoerd, met een **nieuw** verslag.

        - In het testrapport komen alle zaken die volgens het testplan moesten getest worden terug met ernaast of de test succesvol was. Indien er iets fout liep moet er beschreven worden wat er precies mis ging zodat de verantwoordelijke voor dit onderdeel de nodige aanpassingen kan doen.

        - Je kan ook een testscript schrijven dat een aantal zaken in een keer test. Bij de beschrijving van de test omschrijf je dan de procedure om het script uit te voeren en bij het verwachte resultaat plaats je dan een gedetailleerde beschrijving van het resultaat van het testscript.

VM-images en gelijkaardige grote bestanden horen niet in de GitHub repo. Vermijd ook binaire bestanden (bv. docx, pdf, ...) tenzij je niet anders kan (bv. images, Packet Tracer projecten, ...), en geef zoveel mogelijk de voorkeur aan tekstbestanden (bv. markdown, yaml, bash, powershell, ...).

Tenslotte gebruiken we zoveel mogelijk de features van JIRA om te communiceren over "Work in Progress", zowel binnen het team als met de begeleiders.

- Het lastenboek vormt de voorbereiding om in **JIRA tickets** aan te maken

    - Wijs tickets toe aan teamleden. Bij het verplaatsen van een ticket naar de testfase, kan je dan de tester aanduiden.
    - De tester kan nieuwe tickets aanmaken voor de bugs die hij/zij vindt en toekennen aan de verantwoordelijke voor de implementatie.
    - Verwijs in de tickets naar relevante informatie, bv. link naar broncode en documentatie in de GitHub repo.

- **Tijdregistratie** gebeurt eveneens in JIRA

**Vermijd copy-paste van informatie!** Ga bv. geen broncode kopiëren naar de documentatie, maar verwijs er indien nodig naar met links. Je kan in lastenboeken ook bv. meteen linken naar JIRA tickets ipv de inhoud te kopiëren.
