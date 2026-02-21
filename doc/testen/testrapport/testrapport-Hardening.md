# Testrapport – Reverse Proxy Hardening (Nginx)

- **Auteur testrapport:** Ruben Van Bruyssel  
- **Testplan referentie:** Reverse Proxy Hardening (Nginx)  
- **Datum uitvoering:** 2025-09-03  
- **Doel:** Valideren dat de Nginx reverse proxy correct gehard is en geen gevoelige informatie lekt via Nmap  

---

## Test: Server header via Nmap

| Stap | Actie | Verwacht resultaat | Resultaat | Opmerkingen |
|------|-------|------------------|-----------|------------|
| 1 | Scan reverse proxy met `nmap -sV <IP>` | Nmap detecteert **niet het juiste type/version**, toont generiek resultaat of de fake header | ✅ Nmap toont `Apache` | Echte Nginx-versie niet gelekt, banner masking correct |

---

## Overige bevindingen

- Alleen Nmap gebruikt voor fingerprinting  
- Server header is gemaskeerd zoals gewenst  

---

## Conclusie

De server header via Nmap is correct gemaskeerd:  

- Nmap detecteert geen echte Nginx-versie  
- Banner masking werkt effectief  
