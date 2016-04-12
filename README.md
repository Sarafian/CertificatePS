# CertificatePS
Powershell helper module for certificates

| Branch | Status
| ---------- | ---------
| **master** | ![masterstatus](https://asarafian.visualstudio.com/DefaultCollection/_apis/public/build/definitions/9411077a-da68-4370-9d62-7fa8ec77dfa9/12/badge)
| **develop** | ![masterstatus](https://asarafian.visualstudio.com/DefaultCollection/_apis/public/build/definitions/9411077a-da68-4370-9d62-7fa8ec77dfa9/11/badge)

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



