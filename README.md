# CertificatePS
Powershell helper module for certificates

| Branch | Status
| ---------- | ---------
| **master** | ![masterstatus](https://asarafian.visualstudio.com/_apis/public/build/definitions/d1a511ea-5215-45c6-adec-c83eb5ae6bb7/25/badge)
| **develop** | ![developstatus](https://asarafian.visualstudio.com/_apis/public/build/definitions/d1a511ea-5215-45c6-adec-c83eb5ae6bb7/24/badge)

# Commandlets

- Get-CertificateTemplate
- Get-CertificateSubjectInfo
- New-DomainSignedCertificate
- Copy-CertificateToRemote
- Move-CertificateToRemote

# Example script

## Get-CertificateTemplate

```powershell
Get-ChildItem "Cert:\LocalMachine\My" | Select-Object Name,Thumbprint,@{Name="Template";Expression={Get-CertificateTemplate $_}}
```

## Get-CertificateSubjectInfo

```powershell
Get-ChildItem "Cert:\LocalMachine\My" | Get-CertificateSubjectInfo
```

## New-DomainSignedCertificate

```powershell
$authority
New-DomainSignedCertificate -Hostname "example.com" -CertificateAuthority ""
```

To get the `-CertificateAuthority` use `certutil` from a command prompt.

## Copy-CertificateToRemote

```powershell
$certificate=New-DomainSignedCertificate -Hostname "example.com" -CertificateAuthority ""
$pfxPassword=ConvertTo-SecureString “password” -AsPlainText -Force
$certificate|Copy-CertificateToRemote -ComputerName EXAMPLE -PfxPassword $pfxPassword -MoveChain
```

## Move-CertificateToRemote

```powershell
$certificate=New-DomainSignedCertificate -Hostname "example.com" -CertificateAuthority ""
$pfxPassword=ConvertTo-SecureString “password” -AsPlainText -Force
$certificate|Move-CertificateToRemote -ComputerName EXAMPLE -PfxPassword $pfxPassword -MoveChain
```