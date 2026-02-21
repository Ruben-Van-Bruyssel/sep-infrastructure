# Testplan

- Auteur testplan: Ruben Van Bruyssel

## Test: Routerconnectiviteit

| Stap | Actie | Verwacht resultaat |
|------|-------|---------------------|
| 1 | Verbind een PC met het netwerk (geen VLANs). | PC is verbonden met het LAN. |
| 2 | Wijs handmatig een IP-adres toe, bv. `192.168.151.10/24`. | PC heeft een geldig IP-adres. |
| 3 | Stel de gateway in op `192.168.151.2`. | PC gebruikt router als default gateway. |
| 4 | Voer een `ping` uit naar `192.168.151.2`. | Antwoord van de gateway. |
| 5 | Voer een `ping` uit naar extern IP `8.8.8.8`. | Antwoord van extern IP (internet werkt). |
| 6 | Voer een `ping` uit naar `google.com`. | Antwoord van domeinnaam (DNS werkt). |

---

## Test: DHCP functionaliteit

| Stap | Actie | Verwacht resultaat |
|------|-------|---------------------|
| 1 | Verbind een PC met het netwerk. | PC is verbonden met het LAN. |
| 2 | Stel de netwerkadapter in op **DHCP**. | PC vraagt IP-configuratie aan. |
| 3 | Controleer de ontvangen IP-configuratie. | PC krijgt een adres in `192.168.151.0/24`, gateway `192.168.151.2`, en DNS-server. |
| 4 | Voer een `ping` uit naar `192.168.151.2`. | Antwoord van de gateway. |
| 5 | Voer een `ping` uit naar extern IP `8.8.8.8`. | Antwoord van extern IP (internet werkt). |
| 6 | Voer een `ping` uit naar `google.com`. | Antwoord van domeinnaam (DNS werkt). |

