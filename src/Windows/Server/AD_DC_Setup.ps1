# Define Variables
$DomainName = "g07-syndus.internal"  # Domain name
# $SafeModeAdminPassword = ConvertTo-SecureString "Admin_123" -AsPlainText -Force
$IPAddress = "192.168.151.7"
$PrefixLength = 24
$DNS = $IPAddress

# Install the AD DS Role
Write-Host "Installing Active Directory Domain Services..." -ForegroundColor Cyan
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "g07-syndus.internal" -DomainNetbiosName "G07SYNDUS" -InstallDNS


# Configure Static IP (Required for DC)
Write-Host "Configuring Static IP Address..." -ForegroundColor Cyan
$Interface = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
New-NetIPAddress -InterfaceIndex 5 -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceIndex $Interface.ifIndex -ServerAddresses $DNS

# Promote the Server to a Domain Controller
Write-Host "Configuring Domain Controller: $DomainName" -ForegroundColor Cyan
#Install-ADDSForest  -DomainName $domainName 
#-DomainNetbiosName $netBios -ForestMode "WinThreshold" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SafeModeAdministratorPassword $SafeModeAdminPassword -SysvolPath "C:\Windows\SYSVOL" -Force:$true

# Notify User
Write-Host "Domain Controller setup complete. The system will restart in 10 seconds..." -ForegroundColor Green
# Start-Sleep -Seconds 10
# Restart-Computer -Force
