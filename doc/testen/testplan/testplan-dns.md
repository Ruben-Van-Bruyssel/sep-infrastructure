# Testplan

- Auteur testplan: Ruben Van Bruyssel  

## Test: Is het DNS-installatiescript succesvol uitgevoerd?

| Stap | Actie | Verwacht resultaat |
|------|-------|---------------------|
| 1 | Open een nieuw PowerShell-venster. | PowerShell is actief. |
| 2 | Verander de working directory naar de gedeelde map (de project repo). | Je bevindt je in de juiste directory. |
| 3 | Voer `.\DNS_Config.ps1` uit. | Script start en loopt volledig door. |
| 4 | Controleer de output in PowerShell. | - Geen foutmeldingen.<br>- Laatste lijn bevestigt dat de DNS-service actief is.<br>- DNS-service wordt automatisch herstart. |
| 5 | Voer `Get-DnsServerResourceRecord -ZoneName "g07-syndus.internal"` uit. | DNS-records verschijnen in tabelvorm (Name, RecordType, Data). |
| 6 | Controleer of de volgende records aanwezig zijn: | Records komen exact overeen met de configuratie uit het script. |

---

## Verwachte DNS-records in `g07-syndus.internal`

| Name    | RecordType | IPv4Address     |
|---------|------------|-----------------|
| g07-syndus | A      | 192.168.151.5   |
| www     | A          | 192.168.151.18  |
| extra   | A          | 192.168.151.18  |
| matrix  | A          | 192.168.151.18  |
| dc      | A          | 192.168.151.7   |

---

## Verwacht resultaat

- Het script doorloopt zonder fouten.  
- De DNS-service herstart automatisch.  
- De bovenstaande A-records zijn correct aanwezig in de zone **g07-syndus.internal**.  
