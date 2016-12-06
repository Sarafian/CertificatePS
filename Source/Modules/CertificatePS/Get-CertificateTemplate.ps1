<#
    .SYNOPSIS
        This commandlet output the certificate template name

    .DESCRIPTION
        The certificate template name is encapsulated in the Extentions. The commandlets gives a human readable value as you see also from the UI.

    .PARAMETER  Certificate
        A X509Certificate2 instance

    .EXAMPLE
        Get-ChildItem "Cert:\LocalMachine\My" | Get-CertificateTemplate

    .EXAMPLE
        Get-ChildItem "Cert:\LocalMachine\My" | Select-Object Name,Thumbprint,@{Name="Template";Expression={Get-CertificateTemplate $_}}

    .INPUTS
        Any X509Certificate2 certificate

    .OUTPUTS
        The certificate template name

    .LINK
        https://social.technet.microsoft.com/Forums/ie/en-US/187698d0-5602-4301-9d0c-85e89d948ea2/user-powershell-to-get-the-template-used-to-create-a-certificate
#>
function Get-CertificateTemplate {
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
 )
    Process {
        $temp = $Certificate.Extensions | ?{$_.Oid.Value -eq "1.3.6.1.4.1.311.20.2"}
        if (!$temp) {
            $temp = $Certificate.Extensions | ?{$_.Oid.Value -eq "1.3.6.1.4.1.311.21.7"}
        }
        #Sometimes $temp is null
        if($temp){
            $temp.Format(0)
        }
        else
        {
            Write-Warning "Cannot evaluate certificate template"
            "Unknown"
        }
    }
}