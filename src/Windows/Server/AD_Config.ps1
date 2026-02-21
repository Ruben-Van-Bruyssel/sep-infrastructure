# Path to CSV(s)
$pathOUs = "Z:\src\Windows\Server\OUs.csv"
$pathUsers = "Z:\src\Windows\Server\Users.csv"


# OUs aaanmaken
Import-Csv -Path $pathOUs -Delimiter ";" | ForEach-Object {

    $path = $_.Path
    $nameOU = $_.Naam

    New-ADOrganizationalUnit -Name $nameOU -Path $path -ErrorAction SilentlyContinue
}

# Shared folder per gebruiker
function makeDirectory($department, $name) {
    $homePath = "$homeShare\Home"
    $homeShare = "c:\ActiveDirectory\shares\users\$name"    

    createShare -name $name -path $homeShare -user $name
    Set-ADUser $name -ProfilePath "\\g07-syndus\users\$name"
    New-Item -Path $homePath -ItemType Directory -Force
    Set-ADUser $name -HomeDrive $driveLetter -HomeDirectory "\\g07-syndus\users\$name\home"
}

function createShare {
    param(
        [Parameter(Mandatory = $true)]
        [string] $name,
        
        [Parameter(Mandatory = $true)]
        [string] $path,

        [Parameter(Mandatory = $true)]
        [String] $user
        
    )

    if (-not (Test-Path -Path $path)) {
        New-Item -Path $path -ItemType Directory
        New-SmbShare -Name $name -Path $path -FullAccess $user

        $acl = Get-Acl -Path $path
       
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$user", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
       
        $acl.SetAccessRule($accessRule)
    
        Set-Acl -Path $path -AclObject $acl
    }
}

# Gebruikers aanmaken

Import-Csv -Path $pathUsers -Delimiter ";" | ForEach-Object {

    $gebName = $_.Gebruikersnaam
    $dep = $_.Afdeling
    $vNaam = $_.Voornaam
    $aNaam = $_.Achternaam
    $paswd = $(ConvertTo-SecureString $_.Wachtwoord -AsPlainText -Force)

    $Name = $vNaam + "_" + $aNaam

    if (-NOT(Get-ADUser  -Filter { Name -eq $Name })) {
        Switch ($dep) {
            "Admins" {
                New-ADUser -Name $Name -SamAccountName $gebName -GivenName $vNaam -Surname $aNaam -UserPrincipalName "$($gebName)@$($domain)" -Path "OU=NetworkAdministrators,OU=g07-Users,DC=g07-syndus,DC=internal"-AccountPassword $paswd -Enabled $true -department $dep -ChangePasswordAtLogon $False
                Add-ADGroupMember "Domain Admins" $gebName
            }
            "Management" { New-ADUser -Name $Name  -SamAccountName $gebName -GivenName $vNaam -Surname $aNaam -UserPrincipalName "$($gebName)@$($domain)" -Path "OU=Management,OU=g07-Users,DC=g07-syndus,DC=internal"-AccountPassword $paswd -Enabled $true -department $$dep -ChangePasswordAtLogon $False }
            "Development" { New-ADUser -Name $Name  -SamAccountName $gebName -GivenName $vNaam -Surname $aNaam -UserPrincipalName "$($gebName)@$($domain)" -Path "OU=Development,OU=g07-Users,DC=g07-syndus,DC=internal"-AccountPassword $paswd -Enabled $true -department $$dep -ChangePasswordAtLogon $False }
            "HR" { New-ADUser -Name $Name  -SamAccountName $gebName -GivenName $vNaam -Surname $aNaam -UserPrincipalName "$($gebName)@$($domain)" -Path "OU=HR,OU=g07-Users,DC=g07-syndus,DC=internal"-AccountPassword $paswd -Enabled $true -department $dep -ChangePasswordAtLogon $False }
            "Sales" { New-ADUser -Name $Name  -SamAccountName $gebName -GivenName $vNaam -Surname $aNaam -UserPrincipalName "$($gebName)@$($domain)" -Path "OU=Sales,OU=g07-Users,DC=g07-syndus,DC=internal"-AccountPassword $paswd -Enabled $true -department $dep -ChangePasswordAtLogon $False }
            "Public-Relations" { New-ADUser -Name $Name  -SamAccountName $gebName -GivenName $vNaam -Surname $aNaam -UserPrincipalName "$($gebName)@$($domain)" -Path "OU=PublicRelations,OU=g07-Users,DC=g07-syndus,DC=internal"-AccountPassword $paswd -Enabled $true -department $dep -ChangePasswordAtLogon $False }
            "Extern" { New-ADUser -Name $Name -SamAccountName $gebName -GivenName $vNaam -Surname $aNaam -UserPrincipalName "$($gebName)@$($domain)" -Path "OU=Extern,OU=g07-Users,DC=g07-syndus,DC=internal"-AccountPassword $paswd -Enabled $true -department $dep -ChangePasswordAtLogon $False }
        }    
    }
        
    makeDirectory $dep $gebName
}



