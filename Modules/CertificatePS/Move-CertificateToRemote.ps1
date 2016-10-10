<#
    .SYNOPSIS
        Moves a certificate with its chain to the store of a remote computer

    .DESCRIPTION
        Moves a certificate with its chain to the store of a remote computer

    .PARAMETER  Certificate
        The certificate to move

    .PARAMETER  MoveChain
        The password to use when exporting certificates with private key

    .PARAMETER  ComputerName
        Target computer

    .PARAMETER  Credential
        Target Credential

    .PARAMETER  Session
        Target session

    .EXAMPLE
        $certificate=New-DomainSignedCertificate -Hostname "example.com" -CertificateAuthority ""
        $pfxPassword=ConvertTo-SecureString “password” -AsPlainText -Force
        $certificate|Move-CertificateToRemote -ComputerName EXAMPLE -PfxPassword $pfxPassword -MoveChain

    .LINK
        New-DomainSignedCertificate

    .LINK
        Copy-CertificateToRemote
#>

. $PSScriptRoot\Copy-CertificateToRemote.ps1

function Move-CertificateToRemote {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName="Computer")]
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName="Session")]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate,
        [Parameter(Mandatory=$false,ParameterSetName="Computer")]
        [Parameter(Mandatory=$false,ParameterSetName="Session")]
        [securestring]$PfxPassword=$null,
        [Parameter(Mandatory=$false,ParameterSetName="Computer")]
        [Parameter(Mandatory=$false,ParameterSetName="Session")]
        [switch]$MoveChain=$false,
        [Parameter(Mandatory=$true,ParameterSetName="Computer")]
        [AllowNull()]
        $ComputerName=$null,
        [Parameter(Mandatory=$false,ParameterSetName="Computer")]
        [pscredential]$Credential=$null,
        [Parameter(Mandatory=$true,ParameterSetName="Session")]
        [AllowNull()]
        $Session
    )
    Copy-CertificateToRemote @PSBoundParameters
    $Certificate|Remove-Item -Force
}
