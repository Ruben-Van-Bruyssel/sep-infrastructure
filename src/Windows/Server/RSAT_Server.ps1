# Script for the Server VM: Enable Remote Management

# Enable PSRemoting (required for remote management)
Write-Output "Enabling PowerShell Remoting on the server..."
Enable-PSRemoting -Force

# Allow remote management from client machines
Write-Output "Allowing remote management of the server..."
Configure-SMRemoting.exe -Enable

# Configure the server to trust the client IP (use dynamic DHCP IP)
Write-Output "Adding the client IP to Trusted Hosts for remote management..."
Set-Item WSMan:\localhost\Client\TrustedHosts -Value 192.168.151.134

# Restart WinRM service to apply changes
Write-Output "Restarting WinRM service..."
Restart-Service WinRM
