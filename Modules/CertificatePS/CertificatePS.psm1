$names=@(
    "Get-CertificateTemplate"
    "New-DomainSignedCertificate"
)

$names | ForEach-Object {. $PSScriptRoot\$_.ps1 }

Export-ModuleMember $names


