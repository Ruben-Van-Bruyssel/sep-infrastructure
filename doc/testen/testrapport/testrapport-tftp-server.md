# Testrapport – TFTP Server

- Auteur testrapport: Ruben Van Bruyssel  
- Datum uitvoering: 2025-09-03  
- Domein / netwerk: g07-syndus.internal  

---

## Testoverzicht

| Test | Procedure (samenvatting) | Resultaat | Status |
|------|--------------------------|-----------|--------|
| **1. Netwerkverbinding VM** | `vagrant up tftp` uitvoeren en ping naar `192.168.151.2` | VM start zonder errors, ping succesvol | ✅ Geslaagd |
| **2. Inhoud TFTP files** | Via `vagrant ssh` naar `/var/lib/tftpboot` gaan en controleren op `R1_running-config.txt` | Bestand aanwezig | ✅ Geslaagd |
| **3. Werking TFTP server (intern)** | In VM `tftp localhost` → `get Running_config.txt` | Bestand werd succesvol gedownload naar home directory | ✅ Geslaagd |
| **4. Bereikbaarheid vanaf router** | Op router `ping 192.168.151.35` uitvoeren | Router kreeg reply van TFTP server | ✅ Geslaagd |

---

## Detailrapport

### Test 1: Netwerkverbinding VM
- **Procedure:**  
  1. `vagrant up tftp` uitgevoerd  
  2. Installatie volledig laten lopen  
  3. `ping 192.168.151.2` uitgevoerd  
- **Resultaat:**  
  - VM startte zonder errors  
  - Ping naar `192.168.151.2` succesvol  
- **Status:**  Geslaagd  

---

### Test 2: Inhoud TFTP files
- **Procedure:**  
  1. `vagrant ssh tftp` uitgevoerd  
  2. Genavigeerd naar `/var/lib/tftpboot`  
  3. `ls` uitgevoerd  
- **Resultaat:**  
  - Bestand `R1_running-config.txt` aanwezig  
- **Status:**  Geslaagd  

---

### Test 3: Werking TFTP server (intern)
- **Procedure:**  
  1. In VM:  
     ```bash
     tftp localhost
     get Running_config.txt
     ls
     ```  
- **Resultaat:**  
  - Bestand `Running_config.txt` werd succesvol gedownload naar de home directory  
- **Status:**  Geslaagd  

---

### Test 4: Bereikbaarheid TFTP server vanaf router
- **Procedure:**  
  1. Op router:  
     ```bash
     ping 192.168.151.35
     ```  
- **Resultaat:**  
  - Router kreeg reply van TFTP server  
- **Status:** Geslaagd  

---

# Eindconclusie

Alle uitgevoerde tests zijn **succesvol** verlopen.  
De TFTP server is correct geïnstalleerd, bereikbaar via het netwerk en de verwachte configuratiebestanden zijn aanwezig en overdraagbaar.  
