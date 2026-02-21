# Testrapport – Extra Website & Load Balancing (Nginx)

- **Auteur testrapport:** Ruben Van Bruyssel  
- **Testplan referentie:** Extra Website & Load Balancing (Nginx)  
- **Datum uitvoering:** 2025-09-03  
- **Doel:** Valideren dat zowel het hoofd- als het extra serverblok correct werken via de reverse proxy, inclusief HTTPS, load balancing en foutafhandeling.

---

## Test 1: DNS-resolutie

| Stap | Actie | Verwacht resultaat | Resultaat | Opmerkingen |
|------|-------|------------------|-----------|------------|
| 1 | Voeg DNS-record toe voor `extra.g07-syndus.internal` | Domeinnaam resolveert naar het IP van de webserver | Domeinnaam resolveert correct | DNS correct bijgewerkt |
| 2 | Controleer met `ping` of `nslookup` | Domeinnaam wordt correct naar IP vertaald | Correct IP | Ping en nslookup geslaagd |

**Conclusie Test 1:** DNS-resolutie werkt correct voor beide sites.

---

## Test 2: HTTPS-toegang

| Stap | Actie | Verwacht resultaat | Resultaat | Opmerkingen |
|------|-------|------------------|-----------|------------|
| 1 | Surfen naar `https://extra.g07-syndus.internal` | Website laadt correct over HTTPS | Website bereikbaar via HTTPS | Geen certificaatfouten |
| 2 | Controleer SSL-certificaat | Certificaat geldig en correct ingesteld | Certificaat geldig | Certificaat voor extra site correct |
| 3 | Controleer HTTP->HTTPS redirect | HTTP-verkeer wordt automatisch naar HTTPS doorgestuurd | Redirect werkt | Redirect correct geconfigureerd |

**Conclusie Test 2:** HTTPS-toegang en redirect werken correct.

---

## Test 3: Reverse proxy routing & server blocks

| Stap | Actie | Verwacht resultaat | Resultaat | Opmerkingen |
|------|-------|------------------|-----------|------------|
| 1 | Controleer hoofdserverblok (`g07-syndus.internal`) | Verkeer gaat naar `backend_main` | Correct | Requests naar hoofdsite routed naar backend_main |
| 2 | Controleer extra serverblok (`extra.g07-syndus.internal`) | Verkeer gaat naar `backend_extra` | Correct | Requests naar extra site routed naar backend_extra |
| 3 | Controleer isolatie | Verkeer naar het ene blok beïnvloedt het andere niet | Geen verstoring | Beide server blocks onafhankelijk |
| 4 | Controleer proxy headers | `X-Real-IP`, `X-Forwarded-For` en `Host` correct doorgegeven | Headers correct | Header forwarding functioneel |

**Conclusie Test 3:** Reverse proxy routing en server blocks functioneren zoals verwacht.

---

## Test 4: Load balancing

| Stap | Actie | Verwacht resultaat | Resultaat | Opmerkingen |
|------|-------|------------------|-----------|------------|
| 1 | Verkeer naar `backend_main` en `backend_extra` genereren | Verkeer verdeeld over beide servers | Load balancing werkt | Requests verdeeld over servers |
| 2 | Eén backend server uitschakelen | Andere server blijft requests afhandelen | Failover succesvol | Redundantie functioneel |
| 3 | Controleer consistentie | Sessies / stateful data correct afgehandeld | Sessies blijven correct | Sticky sessions niet vereist voor deze test |

**Conclusie Test 4:** Load balancing en failover werken correct.

---

## Test 6: Logging

| Stap | Actie | Verwacht resultaat | Resultaat | Opmerkingen |
|------|-------|------------------|-----------|------------|
| 1 | Controleer access log | Requests per site correct gelogd |  Logs correct | Access logs per site zichtbaar |
| 2 | Controleer error log | Fouten per site correct gelogd | Logs correct | Error logs correct gescheiden |

**Conclusie Test 6:** Logging werkt correct en per site gescheiden.

---

## Algemene conclusie

De Nginx reverse proxy is succesvol geconfigureerd met zowel het hoofd- als het extra serverblok:  

- DNS-resolutie werkt voor beide sites  
- HTTPS-certificaten correct ingesteld en HTTP->HTTPS redirect functioneel  
- Reverse proxy routeert verkeer correct naar `backend_main` en `backend_extra`  
- Load balancing verdeelt verkeer en biedt failover  
- Logging per site correct en gescheiden  
- Beide server blocks functioneren onafhankelijk  
