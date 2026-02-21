# Variables
$GPOName = "UitbreidingGPOs"
$GroupName = "UitbreidingGPOs"
$OULink = "OU=g07-Users,DC=g07-syndus,DC=internal"

# Create GPO
New-GPO -Name $GPOName 

# Link GPO to OU
New-GPLink -Name $GPOName -Target $OULink

# Set Security Filtering
$gpo = Get-GPO -Name $GPOName
Set-GPPermissions -Name $GPOName -PermissionLevel None -TargetName "Authenticated Users" -TargetType Group
Set-GPPermissions -Name $GPOName -PermissionLevel GpoApply -TargetName $GroupName -TargetType Group

# 1. Disable USB and external storage
$Path = "\\$env:USERDOMAIN\SYSVOL\$env:USERDNSDOMAIN\Policies\$($gpo.Id)\User\Registry.pol"
Set-GPRegistryValue -Name $GPOName -Key "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" -ValueName "Start" -Type DWord -Value 4

# 2. Solid color desktop background
Set-GPRegistryValue -Name $GPOName -Key "HKCU\Control Panel\Colors" -ValueName "Background" -Type String -Value "0 0 0"
Set-GPRegistryValue -Name $GPOName -Key "HKCU\Control Panel\Desktop" -ValueName "Wallpaper" -Type String -Value ""
Set-GPRegistryValue -Name $GPOName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" -ValueName "NoChangingWallpaper" -Type DWord -Value 1

# 3. Lock taskbar changes
Set-GPRegistryValue -Name $GPOName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "LockTaskbar" -Type DWord -Value 1

# 4. Prevent saving outside Downloads and network share
# Define base path for personal shares
$HomeSharePath = "\\fileserver\home"

# Redirect Desktop and Documents to personal network share
# This requires the 'User Configuration' part of GPO

# Desktop redirection
Set-GPFolderRedirection -Name $GPOName -Folder "Desktop" -Policy "Basic" `
    -TargetPath "$HomeSharePath\%USERNAME%\Desktop" -GrantUserExclusiveRights $true `
    -Type "RedirectToFollowingLocation"

# Documents redirection
Set-GPFolderRedirection -Name $GPOName -Folder "Documents" -Policy "Basic" `
    -TargetPath "$HomeSharePath\%USERNAME%\Documents" -GrantUserExclusiveRights $true `
    -Type "RedirectToFollowingLocation"


# 5. Auto-delete Downloads folder at logout
# Define paths
$LocalScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir = Split-Path $LocalScriptPath
$CleanupScriptLocal = Join-Path $ScriptDir "wis_downloads.ps1"
# Copy cleanup script to SYSVOL so it's available for all clients
$CleanupScriptDest = "\\$env:USERDOMAIN\SYSVOL\$env:USERDNSDOMAIN\Scripts\wis_downloads.ps1"
Copy-Item -Path $CleanupScriptLocal -Destination $CleanupScriptDest -Force
# Set logoff script (runs when user logs off)
Set-GPLogoffScript -Name $GPOName -ScriptName "wis_downloads.ps1" -ScriptParameters ""


# 6. Block Command Prompt, PowerShell, and Registry Editor
Set-GPRegistryValue -Name $GPOName -Key "HKCU\Software\Policies\Microsoft\Windows\System" -ValueName "DisableCMD" -Type DWord -Value 1
Set-GPRegistryValue -Name $GPOName -Key "HKCU\Software\Policies\Microsoft\Windows\System" -ValueName "EnableScripts" -Type DWord -Value 0
Set-GPRegistryValue -Name $GPOName -Key "HKCU\Software\Policies\Microsoft\Windows\System" -ValueName "DisableRegistryTools" -Type DWord -Value 1
