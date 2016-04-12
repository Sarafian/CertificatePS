# CertificatePS
Powershell helper module for certificates

# Commandlets

- Get-CertificateTemplate
- New-DomainSignedCertificate

# Example script

## Get-CertificateTemplate

```powershell
Get-ChildItem "Cert:\LocalMachine\My" | Select-Object Name,Thumbprint,@{Name="Template";Expression={Get-CertificateTemplate $_}}
```

## New-DomainSignedCertificate

```powershell
$authority
New-DomainSignedCertificate -Hostname "example.com" -CertificateAuthority ""
```

To get the `-CertificateAuthority` use `certutil` from a command prompt.



