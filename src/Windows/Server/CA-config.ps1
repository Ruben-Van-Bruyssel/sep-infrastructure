# Install the ADCS role and tools
Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools

# Import the module (this is important)
Import-Module ADCSDeployment

# Set up Enterprise Root CA
Install-AdcsCertificationAuthority -CAType EnterpriseRootCA `
    -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
    -KeyLength 2048 `
    -HashAlgorithmName SHA256 `
    -ValidityPeriod Years `
    -ValidityPeriodUnits 5

# Export the Root CA cert to a file
$RootCert = Get-ChildItem -Path Cert:\LocalMachine\CA | Select-Object -First 1
Export-Certificate -Cert $RootCert -FilePath "C:\CA\RootCA.cer"

# Create a GPO to distribute the CA cert
New-GPO -Name "DistributeCAcert"
Import-Module GroupPolicy

# Now use Group Policy Management Console (GPMC) to:
# - Edit the GPO
# - Navigate to: Computer Configuration > Policies > Windows Settings > Security Settings > Public Key Policies > Trusted Root Certification Authorities
# - Import the exported C:\CA\RootCA.cer

Write-Host "CA installed and Root CA certificate exported." -ForegroundColor Green
