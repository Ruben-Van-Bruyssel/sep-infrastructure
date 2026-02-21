# Testplan: Linux databank

- Auteur(s) testplan: Gilles De Meerleer

**Opgelet**: de output kan verschillen in een echte opstelling, het gegeven "Verwacht resultaat" voor een test is slechts een placeholder voor een mogelijk geldige output. Het apparaat waar de test op wordt uitgevoerd, staat telkens tussen haakjes in de titel van elke test/stap.

1) Ga naar de juiste directory *(Hostmachine databank-VM)*

```powershell
cd .\src\Vagrant\vagrant-g07\
```

2) Start de databank vm op *(Hostmachine databank-VM)*

```powershell
vagrant up db
```

3) Log in op de vm *(Hostmachine databank-VM)*

```powershell
vagrant ssh db
```

4) Check of SELinux actief is *(Databank-VM)*

```powershell
[vagrant@db ~]$ getenforce
Enforcing
```

5) Bekijk de netwerkinstellingen *(Databank-VM)*

```bash
[vagrant@db ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000        
    link/ether 08:00:27:c7:67:68 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 86289sec preferred_lft 86289sec
    inet6 fd00::3607:c9ea:fe40:4ee0/64 scope global dynamic noprefixroute
       valid_lft 86290sec preferred_lft 14290sec
    inet6 fe80::871c:99df:8955:27d3/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000        
    link/ether 08:00:27:b9:93:af brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet 192.168.151.52/24 brd 192.168.151.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feb9:93af/64 scope link
       valid_lft forever preferred_lft forever
```

1) Test of je de webserver kan pingen *(Databank-VM)*

```bash
[vagrant@db ~]$ ping 192.168.151.60
PING 192.168.151.60 (192.168.151.60) 56(84) bytes of data.
64 bytes from 192.168.151.60: icmp_seq=1 ttl=64 time=5.93 ms
64 bytes from 192.168.151.60: icmp_seq=2 ttl=64 time=1.95 ms
64 bytes from 192.168.151.60: icmp_seq=3 ttl=64 time=1.66 ms
64 bytes from 192.168.151.60: icmp_seq=4 ttl=64 time=1.42 ms
^C
--- 192.168.151.60 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3008ms
rtt min/avg/max/mdev = 1.420/2.739/5.933/1.853 ms
```

7) Check of de Mariadb service actief is *(Databank-VM)*

```bash
[vagrant@db ~]$ sudo systemctl status mariadb
● mariadb.service - MariaDB 11.7.2 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; preset: disabled)
    Drop-In: /etc/systemd/system/mariadb.service.d
             └─migrated-from-my.cnf-settings.conf
     Active: active (running) since Thu 2025-03-27 14:52:36 UTC; 6min ago
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
   Main PID: 6607 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 7 (limit: 13771)
lines 1-10
```

8) Controleer of de MariaDB-service luistert op het juiste IP-adres

```bash
[vagrant@db ~]$ sudo ss -tunlp | grep 3306
tcp   LISTEN 0      80           0.0.0.0:3306      0.0.0.0:*    users:(("mariadbd",pid=6607,fd=35))
```

9) Bekijk de firwall instellingen *(Databank-VM)*

```bash
[vagrant@db ~]$ sudo firewall-cmd  --list-all 
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources: 192.168.151.60
  services: cockpit mysql ssh
  ports: 3306/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Zorg dat bij de rich rules het source address is ingesteld op het ip adres van de webserver.
Hierdoor heeft de web vm toegang tot de MariaDb.

Probeer de Mariadb te gebruiken *(Databank-VM)*

```
[vagrant@db ~]$ sudo mysql -u root -p
```

1)  Bekijk de databanken *(Databank-VM)*

```
[vagrant@db ~]$ sudo mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 10.5.27-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| wordpress_db       |
+--------------------+
4 rows in set (0.002 sec)
```