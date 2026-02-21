# Testplan: Linux databank

- Auteur(s) testplan: Ruben van Bruyssel
Opgelet:
De output kan in een echte opstelling verschillen. Het gegeven "Verwacht resultaat" is slechts een placeholder voor een mogelijke geldige output. Het apparaat waarop de test wordt uitgevoerd, wordt telkens tussen haakjes in de titel van elke test/stap weergegeven.

1) Ga naar de juiste directory (Hostmachine databank-VM)
Navigeer naar de Vagrant-configuratiemap:
```powershell
cd .\src\Vagrant\vagrant-g07\
```



2) Start de ReverseProxy VM op (Hostmachine databank-VM)
Zet de ReverseProxy-VM in beweging:
```powershell
vagrant up ReverseProxy
```


Verwacht resultaat: De output bevestigt dat de ReverseProxy-VM wordt opgestart.

3) Log in op de VM (Hostmachine databank-VM)
Verbind met de VM om de verdere tests lokaal uit te voeren:
```powershell
vagrant ssh ReverseProxy
```


Verwacht resultaat: Het openen van een shell-sessie op de ReverseProxy-VM.

4) Check of SELinux actief is (ReverseProxy-VM)
Controleer of SELinux in de juiste modus draait:
```powershell
[vagrant@reverseproxy ~]$ getenforce
Enforcing
```


Verwacht resultaat: Enforcing (of de verwachte modus). Hierdoor weet je dat SELinux actief is en de beveiligingscontroles hanteert.

5) Controleer de netwerkpoorten (ReverseProxy-VM)
De reverse proxy (bijvoorbeeld Nginx of Apache) moet op de juiste poorten luisteren (standaard 80 voor HTTP en 443 voor HTTPS). Voer het volgende commando uit:
```powershell
[vagrant@reverseproxy ~]$ sudo ss -tunlp | grep -E ':(80|443)'
```

Verwacht resultaat: Een output die bevestigt dat de reverse proxy service actief luistert op 0.0.0.0:80 en 0.0.0.0:443 (of een ander, specifiek IP-adres).

6) Test de reverse proxy routing (ReverseProxy-VM)
Simuleer een verzoek via de reverse proxy door gebruik te maken van het Host-header mechanisme. Dit test of verzoeken correct worden doorgestuurd naar de backend:

```powershell
[vagrant@reverseproxy ~]$ curl -I -H https://www.g07-syndus.internal
[vagrant@reverseproxy ~]$ curl -I -H https://extra.g07-syndus.internal
```
``


Verwacht resultaat: Een HTTP response header met status 200 OK (of een andere geconfigureerde succescode) die bevestigt dat de routering naar de achterliggende server correct werkt.

7) Controleer de access logs (ReverseProxy-VM)
De access logs geven inzicht in welke verzoeken de reverse proxy ontvangt. Zorg dat de logging naar behoren werkt:
```powershell
[vagrant@reverseproxy ~]$ tail -n 20 /var/log/nginx/access.log
```


Verwacht resultaat: Recente logregels met daarin tijdstempels, het bron-IP en de details van het verzoek. (Pas het pad aan indien een andere logginglocatie gebruikt wordt.)

8) Controleer de audit logs (ReverseProxy-VM)
Audit logs (bijvoorbeeld via SELinux of een andere audit daemon) bieden inzicht in beveiligingsgerelateerde acties en mogelijke denials. Zoek bijvoorbeeld naar recente SELinux-denials:
```powershell
[vagrant@reverseproxy ~]$ sudo ausearch -m avc -ts today
```

Verwacht resultaat: Geen onverwachte DENY of foutmeldingen. Als er wel meldingen zijn, moeten deze gecontroleerd worden op eventuele misconfiguraties in de reverse proxy of SELinux policies.

9) Voer nslookup tests uit (ReverseProxy-VM)
Controleer de DNS-resolutie van de backend server(s) door een nslookup uit te voeren:
```powershell
[vagrant@reverseproxy ~]$ nslookup www.g07-syndus.internal
[vagrant@reverseproxy ~]$ nslookup extra.g07-syndus.internal
```


Verwacht resultaat: De tool geeft het correcte IP-adres weer dat is gekoppeld aan backend.example.com.
Optioneel kun je ook een lokale DNS-check uitvoeren:
[vagrant@reverseproxy ~]$ nslookup localhost


Verwacht resultaat: De resolutie localhost naar 127.0.0.1.

10) Extra tests: Beveiliging en foutafhandeling (ReverseProxy-VM)
a) Test foutafhandeling bij ongeldige host headers
Simuleer een verzoek naar een niet-geconfigureerde hostnaam om te controleren hoe de reverse proxy hiermee omgaat:
```powershell
[vagrant@reverseproxy ~]$ curl -I -H https://www.g07-syndus.internal
[vagrant@reverseproxy ~]$ curl -I -H https://extra.g07-syndus.internal
```


Verwacht resultaat: Een foutmelding zoals 404 Not Found of een andere door jouw configuratie gedefinieerde respons voor onbekende hosts.
b) Test gelaagde logging
Indien je loggingniveaus hebt gedefinieerd (bijvoorbeeld voor debugdoeleinden), wijzig tijdelijk de loggingconfiguratie en voer een testverzoek uit. Bekijk daarna de error logs:
```powershell
[vagrant@reverseproxy ~]$ tail -n 20 /var/log/nginx/error.log
```


