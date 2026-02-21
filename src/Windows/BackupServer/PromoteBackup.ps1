# Install AD
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Promote to DC
Import-Module ADDSDeployment

Install-ADDSDomainController `
    -DomainName "g07-syndus.internal" `
    -InstallDns `
    -Credential (Get-Credential) `
    -ReplicationSourceDC "G07-SYNDUS.g07-syndus.internal" `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force

# post-restart
# repadmin /replsummary
# dcdiag

