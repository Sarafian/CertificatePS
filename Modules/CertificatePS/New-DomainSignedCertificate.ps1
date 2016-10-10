<#
    .SYNOPSIS
        This commandlet requests a certificate from the active directory certificate services and adds it to the store

    .DESCRIPTION
        This commandlet requests a certificate from the active directory certificate services and adds it to the store. The commandlet automates the flow of certreq.exe.

    .PARAMETER  Hostname
        The hostname of the certificate also known as the Common Name (CN)

    .PARAMETER  Organization
        The organization of the certificate (O)

    .PARAMETER  OrganizationalUnit
        The organization unit of the certificate (OU)

    .PARAMETER  Locality
        The locality unit of the certificate also known as the city (L)

    .PARAMETER  State
        The state of the certificate (S)

    .PARAMETER  Country
        The country of the certificate (C)

    .PARAMETER  CertificateAuthority
        The the certificate authority that will issue the certificate. For a sever attached to a domain use the certutil to find the value.

    .PARAMETER  FriendlyName
        The friendly name of the certificate. Default use the yyyyMMdd.hostname

    .PARAMETER  Keylength
        The key length of the certificate

    .PARAMETER  workdir
        The path where the temporary files are generated. Default is the %temp%

    .EXAMPLE
        New-DomainSignedCertificate -Hostname "example.com" -CertificateAuthority ""

    .LINK
        http://serverfault.com/questions/670160/how-can-i-create-and-install-a-domain-signed-certificate-in-iis-using-powershell
#>
function New-DomainSignedCertificate {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]
        $Hostname,

        [parameter(Mandatory=$false)]
        [string]
        $Organization="",

        [parameter(Mandatory=$false)]
        [string]
        $OrganizationalUnit="",

        [parameter(Mandatory=$false)]
        [string]
        $Locality="",

        [parameter(Mandatory=$false)]
        [string]
        $State="",

        [parameter(Mandatory=$false)]
        [string]
        $Country="",

        [parameter(Mandatory=$true)]
        [string]
        $CertificateAuthority,

        [parameter(Mandatory=$false)]
        [string]
        $FriendlyName="$(Get-Date -Format "yyyyMMdd").$Hostname",

        [parameter(Mandatory=$false)]
        [string]
        $Keylength = "2048",

        [string]
        $workdir = $env:Temp
    )

    $fileBaseName = $Hostname -replace "\.", "_" 
    $fileBaseName = $fileBaseName -replace "\*", ""

    $infFile = $workdir + "\" + $fileBaseName + ".inf"
    $requestFile = $workdir + "\" + $fileBaseName + ".req"
    $CertFileOut = $workdir + "\" + $fileBaseName + ".cer"

    Try {
        Write-Verbose "Creating the certificate request information file ..."
        $inf = @"
[Version] 
Signature="`$Windows NT`$"

[NewRequest]
Subject = "CN=$Hostname, OU=$OrganizationalUnit, O=$Organization, L=$Locality, S=$State, C=$Country"
KeySpec = 1
KeyLength = $Keylength
Exportable = TRUE
FriendlyName = "$FriendlyName"
MachineKeySet = TRUE
SMIME = False
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0
"@

        $inf | Set-Content -Path $infFile -Force

        Write-Verbose "Creating the certificate request ..."
        $certreqArgs=@(
            "-new"
            $infFile
            $requestFile
        )
        Start-Process -FilePath "certreq.exe" -ArgumentList $certreqArgs -NoNewWindow -Wait

        $certreqArgs=@(
            "-submit"
            "-config"
            $CertificateAuthority
            "-attrib"
            "CertificateTemplate:WebServer"
            $requestFile
            $CertFileOut
        )
        Write-Verbose "Submitting the certificate request to the certificate authority ..."
        Start-Process -FilePath "certreq.exe" -ArgumentList $certreqArgs -NoNewWindow -Wait

        if (Test-Path "$CertFileOut") {
            Write-Verbose "Installing the generated certificate ..."
            $certreqArgs=@(
                "-accept"
                $CertFileOut
            )
            Start-Process -FilePath "certreq.exe" -ArgumentList $certreqArgs -NoNewWindow -Wait
            $certificate=[System.Security.Cryptography.X509Certificates.X509Certificate2]::CreateFromCertFile($CertFileOut)
            $certificate2=New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $certificate
            Get-ChildItem Cert:\LocalMachine\My |Where-Object -Property Thumbprint -EQ $certificate2.Thumbprint
        }
    }
    Finally {
        Get-ChildItem "$workdir\$fileBaseName.*" | remove-item
    }
}