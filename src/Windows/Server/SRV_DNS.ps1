# -------------------------------
# DNS Setup for Domain Controller
# Hostname: g07-SYNDUS
# Domain: g07-syndus.internal
# IP Address: 192.168.151.7
# -------------------------------

# Define variables
$DomainName = "g07-syndus.internal"
$DCName = "G07-SYNDUS"
$DCIP = "192.168.151.7"
$DCFQDN = "$DCName.$DomainName"
$MSDCSZone = "_msdcs.$DomainName"

# -------------------------------
# 1. Create A-record for DC
# -------------------------------
Add-DnsServerResourceRecordA -Name $DCName -ZoneName $DomainName -IPv4Address $DCIP

# -------------------------------
# 2. Create SRV records in _msdcs zone
# -------------------------------

# LDAP for domain controllers
Add-DnsServerResourceRecord -ZoneName $MSDCSZone `
    -Name "_ldap._tcp.dc" `
    -Srv `
    -DomainName $DCFQDN `
    -Priority 0 -Weight 100 -Port 389 -TimeToLive 00:10:00

# Kerberos for domain controllers
Add-DnsServerResourceRecord -ZoneName $MSDCSZone `
    -Name "_kerberos._tcp.dc" `
    -Srv `
    -DomainName $DCFQDN `
    -Priority 0 -Weight 100 -Port 88 -TimeToLive 00:10:00

# LDAP for global catalog
Add-DnsServerResourceRecord -ZoneName $MSDCSZone `
    -Name "_ldap._tcp.gc" `
    -Srv `
    -DomainName $DCFQDN `
    -Priority 0 -Weight 100 -Port 3268 -TimeToLive 00:10:00

# Kerberos for global catalog
Add-DnsServerResourceRecord -ZoneName $MSDCSZone `
    -Name "_kerberos._tcp.gc" `
    -Srv `
    -DomainName $DCFQDN `
    -Priority 0 -Weight 100 -Port 88 -TimeToLive 00:10:00

# -------------------------------
# 3. Optional SRV records in parent zone
# -------------------------------

# LDAP for general clients
Add-DnsServerResourceRecord -ZoneName $DomainName `
    -Name "_ldap._tcp" `
    -Srv `
    -DomainName $DCFQDN `
    -Priority 0 -Weight 100 -Port 389 -TimeToLive 00:10:00

# Kerberos for general clients
Add-DnsServerResourceRecord -ZoneName $DomainName `
    -Name "_kerberos._tcp" `
    -Srv `
    -DomainName $DCFQDN `
    -Priority 0 -Weight 100 -Port 88 -TimeToLive 00:10:00