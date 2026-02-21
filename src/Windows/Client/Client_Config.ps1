# Definieer netwerkinstellingen
$InterfaceAlias = "Ethernet"  # Verander dit naar de naam van je netwerkadapter
$DNSServers = @("192.168.151.54", "8.8.8.8")

# Schakel DHCP in voor IP-adresconfiguratie
Write-Output "DHCP wordt ingeschakeld voor IP-adres..."
Set-NetIPInterface -InterfaceAlias $InterfaceAlias -Dhcp Enabled

# Verkrijg een nieuw IP-adres van de DHCP-server
Write-Output "Een nieuw IP-adres wordt verkregen via DHCP..."
ipconfig /renew

# DNS-servers handmatig instellen
Write-Output "DNS-servers worden ingesteld..."
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DNSServers

Write-Output "DHCP-configuratie en DNS-instellingen succesvol toegepast!"

