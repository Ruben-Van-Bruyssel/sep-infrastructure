$DomainName = "g07-syndus.internal"
$DNSForwarders = "8.8.8.8", "8.8.4.4"
$NetworkID = "192.168.151.0/24"

# DNS Server installeren
Install-WindowsFeature -Name DNS -IncludeManagementTools
Set-DnsServerForwarder -IPAddress $DNSForwarders

# Forward Lookup Zone (aanmaken als ze niet bestaat)
if (-not (Get-DnsServerZone -Name $DomainName -ErrorAction SilentlyContinue)) {
    Add-DnsServerPrimaryZone -Name $DomainName -ZoneFile "$DomainName.dns"
}

# Reverse Lookup Zone (aanmaken als ze niet bestaat)
if (-not (Get-DnsServerZone -Name "151.168.192.in-addr.arpa" -ErrorAction SilentlyContinue)) {
    Add-DnsServerPrimaryZone -NetworkID $NetworkID -ZoneFile "151.168.192.in-addr.arpa"
}

# A Records
Add-DnsServerResourceRecordA -Name "g07-syndus" -ZoneName $DomainName -IPv4Address "192.168.151.5" -CreatePtr -ErrorAction SilentlyContinue
Add-DnsServerResourceRecordA -Name "www" -ZoneName $DomainName -IPv4Address "192.168.151.18" -CreatePtr -ErrorAction SilentlyContinue
Add-DnsServerResourceRecordA -Name "extra" -ZoneName $DomainName -IPv4Address "192.168.151.18" -CreatePtr -ErrorAction SilentlyContinue
Add-DnsServerResourceRecordA -Name "matrix" -ZoneName $DomainName -IPv4Address "192.168.151.18" -CreatePtr -ErrorAction SilentlyContinue
Add-DnsServerResourceRecordA -Name "dc" -ZoneName $DomainName -IPv4Address "192.168.151.7" -CreatePtr -ErrorAction SilentlyContinue

Write-Host "DNS-configuratie voor $DomainName is voltooid."
