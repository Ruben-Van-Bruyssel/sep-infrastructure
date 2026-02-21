# Testplan

- Uitvoerder(s) test: Ruben Van Bruyssel
- Uitgevoerd op: 03/09/2025
- Github commit: <!-- Git commit hash. -->

## Test: Kan men inloggen als gewone gebruiker zo wel als domain administrator op de WINCLIENT?

Testprocedure:

1. Controleer via Settings > System > About als de client in de g07-syndus.internal domain zit.
2. Log uit als admin van WINCLIENT
3. Log in als Administrator@g07-syndus.internal
4. Switch User naar een normaal gebruiker 

Verkregen resultaat:

- Er wordt zonder probleem ingelogd als admin van de g07 domain (domain controller)
- Er wordt zonder probleem ingelogd als Ruben binnen de g07 domain (gewone gebruiker)

Test geslaagd:

- [x] Ja
- [ ] Nee

Opmerkingen:

- niet geslaagd op WINCLIENT1 maar wel op WINCLIENT
