# Script for the Client VM: Install RSAT and Connect to Server

# Install RSAT tools for Windows 10
Write-Output "Installing RSAT tools on the client..."
Get-WindowsCapability -Name RSAT* -Online | ForEach-Object { Add-WindowsCapability -Online -Name $_.Name }

# Confirm RSAT tools installation
Write-Output "Confirming RSAT tools installation..."
Get-WindowsCapability -Name RSAT* -Online | Where-Object State -eq "Installed"

# Wait for RSAT installation to complete
Write-Output "RSAT tools installed successfully."

# Prompt for server IP (replace <ServerIP> with the actual server IP)
$ServerIP = "192.168.151.54"

# Test connectivity to the server
Write-Output "Testing connectivity to the server at $ServerIP..."
Test-Connection -ComputerName $ServerIP -Count 4

# Attempt remote PowerShell session connection
Write-Output "Attempting to connect to the server using remote PowerShell..."
Enter-PSSession -ComputerName $ServerIP -Credential (Get-Credential)

Write-Output "Connected to the server successfully!"

