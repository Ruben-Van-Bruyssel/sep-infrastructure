# Instructies

Dit document bevat instructies voor het opstarten van het project, het gebruik van deze repository, enz.

## Voorbereiding

Volgende taken worden door **één groepslid** uitgevoerd:

- Maak de centrale GitHub repo aan via de GitHub classroom link. Je maakt een nieuwe groep aan met de naam zoals op Chamilo (G01 - G13, A01 - G02, T01).
- Maak de Jira site aan en configureer deze.
- Maak het kanban bord aan.

Volgende taken dienen door **elk groepslid** uitgevoerd te worden:

- Ga naar de Github Classroom link en sluit aan bij jouw team.
- Vul de tabel bovenaan dit document aan met jouw naam en GitHub gebruikersnaam.
- Lees de [studiewijzer](./studiewijzer.md) en alle `README.md` bestanden in de repository goed door.

Volgende taken dienen **als team** uitgevoerd te worden:

- Opstellen roadmap. Dit is een visueel overzicht van de 12 weken planning van het project. Dit kan je doen in Jira. Ten laatste tegen week 3 is een eerste draft aangemaakt.
    - Leg de werkverdeling voor de eerste week vast.
    - Voeg de planning toe aan het kanban bord: maak de juiste tickets aan.
- Lees je in en doe research voor bepaalde onderwerpen.

Op Chamilo kan je ook de slides van de kick-off terugvinden en de opname ervan herbekijken.

## Gebruik van Git en Github

Je hebt in de opleiding al eerder gebruik gemaakt van Git en Github, dus we veronderstellen dat je daar in elk geval mee aan de slag kan.

In dit project werk je wel met meer mensen samen aan dezelfde codebase dan je tot nu toe gewend bent. Daardoor vergroot de kans op merge-conflicten. Er zijn verschillende strategieën om dit te vermijden. Je kan als team zelf beslissen hoe je dit gaat aanpakken.

Voor algemene richtlijnen over een goede configuratie van Git op je eigen laptop en het efficiënt samenwerken, verwijzen we naar onze [Git/Github gebruikersgids @HOGENT](https://hogenttin.github.io/git-hogent-gids/). Volg zeker de instructies rond [Installatie en configuratie](https://hogenttin.github.io/git-hogent-gids/installatie-config/)!

## Algemene richtlijnen

## Algemene richtlijnen

Eerst en vooral is een goede, **overzichtelijke directorystructuur** belangrijk. Mergeconflicten komen vooral voor wanneer verschillende personen tegelijk hetzelfde bestand bewerken. Als je goede afspraken maakt over wie welke bestanden bewerkt, vermijd je al veel problemen.

**Goede commit-boodschappen** zijn ook des te belangrijker om aan je teamleden te communiceren wat je precies gedaan hebt ( https://chris.beams.io/posts/git-commit/ ). Aan boodschappen als "wijzigingen", "fix", "herwerken", "brol", "plz work", enz. heeft niemand iets: noch de begeleiders, noch je teamleden, noch je toekomstige zelf. Je kan afspraken maken over prefixen die aangeven aan welke taak je gewerkt hebt, bv. de hostnaam van de server waaraan je gewerkt hebt: "[bravo]", of algemene aanduidingen als "[doc]", "[fix]", enz. Het nummer van de Git issue kan ook informatief zijn, bv. "[bravo #13]", "[doc #36]", "[fix #42]", enz. Het laatste voorbeeld zal ook Issue #42 sluiten (zorg dus dat je zeker bent dat de issue wel degelijk opgelost is!).

Hou **commits zo klein mogelijk**. Maak zeker niet de fout om slechts één of enkele keren per week een grote commit uit te voeren. Wacht ook niet tot je een component volledig afgewerkt hebt, maar registreer ook deelresultaten. Hoe groter een commit en hoe langer je code niet gesynchroniseerd is met de centrale Git repository, des te meer kansen op merge-conflicten. Commit dus meerdere keren per werksessie, en telkens je één concrete stap vooruit raakt.

**Synchroniseer** ook **heel regelmatig** met de centrale Git repository. Minstens aan het einde van elke sessie dat je aan het project werkt, maar vaker mag zeker.

**Overschrijf nooit publieke historiek**, en gebruik dus **nooit** de volgende commando's:

```console
# Doe het volgende NOOIT!
git reset --hard
git push --force
```

Dit zal voor alle teamleden leiden tot conflicten en mogelijks tot **verlies** van geleverd werk. Als je in je eigen werkkopie van de repository terug wil naar de toestand in een vorige commit, gebruik je `git revert`.
