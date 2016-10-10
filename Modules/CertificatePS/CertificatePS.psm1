$names=@(
    "Get-CertificateTemplate"
    "New-DomainSignedCertificate"
    "Move-CertificateToRemote"
    "Copy-CertificateToRemote"
)

$names | ForEach-Object {. $PSScriptRoot\$_.ps1 }

Export-ModuleMember $names


