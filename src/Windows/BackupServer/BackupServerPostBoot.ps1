# IP config
netsh interface ip set address name="Ethernet" static 192.168.207.58 255.255.255.240 192.168.207.49
netsh interface ipv4 set interface 5 dadtransmits=0 store=persistent

# Disable Firewall
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False

# Rename Computer 
Rename-Computer -NewName "BackupServer"
Restart-Computer

# Join Domain after restart
# Add-Computer -DomainName g07-syndus.internal -Credential Administrator@g07-syndus.internal
# Restart-Computer