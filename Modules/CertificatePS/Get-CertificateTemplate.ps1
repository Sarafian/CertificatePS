# https://social.technet.microsoft.com/Forums/ie/en-US/187698d0-5602-4301-9d0c-85e89d948ea2/user-powershell-to-get-the-template-used-to-create-a-certificate?forum=winserversecurity
function Get-CertificateTemplate {
[CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Security.Cryptography.X509Certificates.X509Certificate2]$cert
 )
    Process {
        $temp = $cert.Extensions | ?{$_.Oid.Value -eq "1.3.6.1.4.1.311.20.2"}
        if (!$temp) {
            $temp = $cert.Extensions | ?{$_.Oid.Value -eq "1.3.6.1.4.1.311.21.7"}
        }
        $temp.Format(0)
    }
}