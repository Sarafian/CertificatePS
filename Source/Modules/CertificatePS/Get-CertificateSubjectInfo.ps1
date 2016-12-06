<#
    .SYNOPSIS
        This commandlet breaks down the certificate's subject into the Common Name, Organizational Unit, Organization, Locality, State and Country

    .DESCRIPTION
        This commandlet breaks down the certificate's subject into the Common Name, Organizational Unit, Organization, Locality, State and Country

    .PARAMETER  Certificate
        A X509Certificate2 instance

    .EXAMPLE
        Get-ChildItem "Cert:\LocalMachine\My" | Get-CertificateSubjectInfo

    .INPUTS
        Any X509Certificate2 certificate


    .LINK
        https://social.technet.microsoft.com/Forums/ie/en-US/187698d0-5602-4301-9d0c-85e89d948ea2/user-powershell-to-get-the-template-used-to-create-a-certificate
#>
function Get-CertificateSubjectInfo {
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
 )
    Process {

        $hash=[ordered]@{
            Subject=$Certificate.Subject
            FriendlyName=$Certificate.FriendlyName
            CommonName=$null
            OrganizationalUnit=$null
            Organization=$null
            Locality=$null
            State=$null
            Country=$null
        }
        $Certificate.Subject -split ', ' |ForEach-Object {
            switch ($_)
            {
                {$_ -like "CN=*"} {
                    $hash.CommonName=$_.SubString(3)
                    break
                }
                {$_ -like "OU=*"} {
                    $hash.OrganizationalUnit=$_.SubString(3)
                    break
                }
                {$_ -like "O=*"} {
                    $hash.Organization=$_.SubString(2)
                    break
                }
                {$_ -like "L=*"} {
                    $hash.Locality=$_.SubString(2)
                    break
                }
                {$_ -like "S=*"} {
                    $hash.State=$_.SubString(2)
                    break
                }
                {$_ -like "C=*"} {
                    $hash.Country=$_.SubString(2)
                    break
                }
            }
        }
        New-Object -TypeName psobject -Property $hash
    }
}

Get-ChildItem "Cert:\LocalMachine\My" | Get-CertificateSubjectInfo|Format-Table