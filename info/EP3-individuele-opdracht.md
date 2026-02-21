# Individuele opdracht EP3

Wanneer je kiest om de opdracht individueel aan te pakken dan laten we toe om de gehele setup uit te werken in VirtualBox op één laptop. Het is toegelaten dat alle machines zich bevinden in 1 subnetwerk, <u>zonder VLANs</u> – dit laat je toe alle servers te testen op je eigen laptop. **De basisopdracht blijft, op het netwerkgedeelte na, ongewijzigd.** Je kiest voor minstens één nieuwe uitbreiding die je in jouw team in EP2 nog niet maakte. Jouw skills in het configureren van netwerkapparatuur toon je enerzijds aan door een packet tracer setup voor te bereiden (cfr. paragraaf [Netwerkopdracht](#netwerkopdracht)), anderzijds sluit je jouw opstelling (zonder VLANs) aan op het klasnetwerk tijdens je demo-moment (cfr. paragraaf [Flat network](#flat-network)).


## Netwerkopdracht

Tijdens je demo configureer je zelf NAT op een uplink router; je sluit je laptop aan op een switch die verbindt naar de LAN kant van jouw router. De WAN kant gebruikt het klasnetwerk (de default gateway in het klasnetwerk is 172.22.255.254; de DNS server is 172.22.128.1.).

Je werkt eveneens een packet tracer (PT) voorbereiding uit die deze ‘basic NAT’ opstelling bevat. Je kan starten vanaf het bestand [SEP-EP3-simulatie](SEP-EP3-simulatie.pkt). De client moet kunnen surfen naar (het gesimuleerde) www.hogent.internal in deze PT set-up.


## Flat network

Opdelen in subnets vervalt – je sluit al jouw VMs aan op één en hetzelfde netwerk, binnen de range 192.168.151.0/24. Hoe je dit netwerk op je laptop in VirtualBox opstelt, is een keuze: het staat je vrij om in VirtualBox te experimenteren en een voorstel in te dienen. Zorg er dan echter voor dat je dit goed argumenteert. Probeer geen onnodige netwerkkaarten aan je virtuele machines toe te voegen! Speel je liever op safe dan staat hieronder een werkbare VirtualBox netwerk setup beschreven waarmee je aan de slag kan gaan.
Tijdens je demo-moment switch je alle VMs naar **bridged mode** als je ze aansluit op de switch van je eigen (demo-)netwerk.


## Addendum: VirtualBox Host-only suggestie

Merk op dat dit equivalent is aan de setup die gebruikt wordt in het olod Cybersecurity en Virtualisation; je kan en mag de bestaande Debian router dus hergebruiken.

**Setup – host-only netwerk voorzien van internet (deze beschrijving is ook te vinden in het leerpad van cybersecurity en virtualisatie, puntje 2.2.3)**:

1. Maak een host-only netwerk aan in VirtualBox via VBoxManager (CLI) of in de GUI via “File” > “Tools” > “Network Manager” met volgende eigenschappen.

	a. Adapter: “Configure Adapter Manually” en kies een IPv4 Adres (bijvoorbeeld 192.168.50.1) en IPv4 Network Mask (bijvoorbeeld 255.255.255.0).

	b. Zorg ervoor dat bij de tab DHCP Server er geen Server draait, met andere woorden, Enable Server heeft **geen** vinkje.

2. Maak een Linux router machine. De setup is het vaakst getest op debian, we raden dus aan om een Debian machine op te zetten. Dit kan via vagrant, osboxes maar een clean install gaat ook vlot vanaf de iso. Zorg ervoor dat dit geen grafische interface heeft.

3. Zorg ervoor dat deze machine 2 NIC’s heeft. De eerste is verbonden met de default NAT van VirtualBox. De tweede verbind je met het host-only netwerk dat je gemaakt hebt in de eerste stap.

4. Voer onderstaande commando’s uit, of kopieer het als script. Zorg ervoor dat je root rechten hebt. Het is mogelijk dat je dit script meermaals moet uitvoeren om alles in orde te krijgen. Probeer na te gaan wat je doet en te troubleshooten waar nodig. Controleer opnieuw de interface namen.

5. Elke virtuele machine die nu op dit host-only netwerk verbindt, zal via DHCP een IP-adres krijgen. Wil je dit niet dan moet je het statisch instellen. Wijzig de DHCP range indien gewenst.

**Router script**

```bash
#!/bin/bash

apt update && apt upgrade -y
apt install vim bind9 isc-dhcp-server -y

# Enable routing

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
/usr/sbin/sysctl -p

# Setup static IP

/usr/bin/cat << EOF >> /etc/network/interfaces.d/enp0s8
allow-hotplug enp0s8
iface enp0s8 inet static
    address 192.168.50.10
    netmask 255.255.255.0
EOF

# Setup Bind/DNS

/usr/bin/cat << EOF > /etc/bind/named.conf.options
  options {
      directory "/var/cache/bind";

      listen-on port 53 { any; };
      allow-query { any; };
      recursion yes;
      dnssec-validation no;
      forwarders {
              1.1.1.1;
      };
      forward only;

  };
EOF

systemctl enable named
systemctl start named

# Enable NAT'ing

systemctl enable nftables
systemctl start nftables

/usr/bin/cat << EOF > /etc/nftables.conf
#!/usr/sbin/nft -f

# Flush the rule set

flush ruleset

# Create a nat table

add table nat
add chain nat prerouting { type nat hook prerouting priority -100 ; }
add chain nat postrouting { type nat hook postrouting priority 100 ; }
add rule nat postrouting oifname "enp0s3" masquerade
EOF

# Configure and enable DHCP

/usr/bin/cat << EOF > /etc/default/isc-dhcp-server
INTERFACESv4="enp0s8"
EOF

/usr/bin/cat << EOF > /etc/dhcp/dhcpd.conf

# dhcpd.conf

option domain-name "hogent.local";
option domain-name-servers 192.168.50.10;

default-lease-time 600;
max-lease-time 7200;

ddns-update-style none;

subnet 192.168.100.0 netmask 255.255.255.0 {
    range 192.168.50.11 192.168.50.100;
    option routers 192.168.50.10;
    option subnet-mask 255.255.255.0;
}
EOF

reboot
```
