# Testplan – Reverse Proxy Hardening (Nginx)

- Auteur testplan: Ruben Van Bruyssel  
- Doel: Valideren dat de Nginx reverse proxy correct gehard is en geen informatie lekt  
- Datum uitvoering: 2025-09-03  

---

## Test 1: Server header en versie

| Stap | Actie | Verwacht resultaat |
|------|-------|------------------|
| 1 | Check HTTP headers van de server | `curl -I http://<reverse-proxy>` toont `Server: Apache` (of een generiek label) |
| 2 | Controleer dat `ServerTokens` uit staat | Geen versieinformatie in `Server` header zichtbaar |
| 3 | Controleer custom server header met `more_set_headers` | Header toont de ingestelde fake waarde (`Apache`) |

---

## Test 5: Banner en fingerprinting (Nmap)

| Stap | Actie | Verwacht resultaat |
|------|-------|------------------|
| 1 | Scan reverse proxy met `nmap -sV` | Nmap detecteert **niet het juiste type/version**, toont generiek resultaat of de fake header |
| 2 | Controleer dat andere fingerprinting tools (Nikto, OWASP ZAP) geen serverversie lekken | Geen versie of type informatie zichtbaar |

---

## Verwachte resultaten

- HTTP headers tonen **geen softwareversie** en server type is gemaskeerd   
- Security headers aanwezig en actief  
- Nmap en andere fingerprinting tools kunnen geen accurate server info detecteren  
