<#
    .SYNOPSIS
        Copies a certificate with its chain to the store of a remote computer

    .DESCRIPTION
        Copies a certificate with its chain to the store of a remote computer

    .PARAMETER  Certificate
        The certificate to copy

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
        $certificate|Copy-CertificateToRemote -ComputerName EXAMPLE -PfxPassword $pfxPassword -MoveChain

    .LINK
        New-DomainSignedCertificate

    .LINK
        Move-CertificateToRemote
#>
function Copy-CertificateToRemote {
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

    try {
        if($Certificate.HasPrivateKey)
        {
            if(-not $PfxPassword)
            {
                throw "Parameter PfxPassword is required to move a certificate with private key"
            }
        }

        $identifier=$Certificate.Thumbprint
        #Export certificate to temp
        $exportPath=Join-Path $env:TEMP $identifier
        if(Test-Path $exportPath)
        {
            Remove-Item $exportPath -Recurse -Force
        }
        New-Item $exportPath -ItemType Directory|Out-Null
        [int]$iteration=1
        if($Certificate.HasPrivateKey)
        {
            $pfxPath=Join-Path $exportPath "$("{0:00}" -f $iteration).$($Certificate.Thumbprint).pfx"
            $Certificate |Export-PfxCertificate -FilePath $pfxPath -ChainOption BuildChain -Password $PfxPassword|Out-Null
        }
        else
        {
            $cerPath=Join-Path $exportPath "$("{0:00}" -f $iteration).$($Certificate.Thumbprint).cer"
            $Certificate |Export-Certificate -FilePath $cerPath -ChainOption BuildChain -Password $pfxPassword|Out-Null
        }

        if($MoveChain)
        {
            $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
            if($chain.Build($Certificate))
            {
                $chain.ChainElements|Select-Object -ExpandProperty Certificate -Skip 1|ForEach-Object {
                    $iteration++
                    $cerPath=Join-Path $exportPath "$("{0:00}" -f $iteration).$($_.Thumbprint).cer"
                    $_|Export-Certificate -FilePath $cerPath|Out-Null
                }
            }
        }

        if($ComputerName)
        {
            if($Credential)
            {
                $Session=New-PSSession -ComputerName $ComputerName -Credential $Credential
            }
            else
            {
                $Session=New-PSSession -ComputerName $ComputerName
            }
        }

        #Copy certificate to remote temp directory
        $prepareDirectoryBlock = {
            $importPath=Join-Path $env:TEMP $Using:identifier
            if(Test-Path $importPath)
            {
                $null=Remove-Item $importPath -Recurse -Force
            }
            (New-Item $importPath -ItemType Directory).FullName
        }
        $importAbsolutePathOnRemote=Invoke-Command -Session $Session -ScriptBlock $prepareDirectoryBlock -HideComputerName
        Copy-Item -Path "$exportPath\*.*" -Destination $importAbsolutePathOnRemote -ToSession $session -Force|Out-Null

        #Import certificate on remote
        $importBlock= {
            $importPath=$Using:importAbsolutePathOnRemote
            try 
            {
                Get-ChildItem -Path $importPath | Sort-Object -Property Name | ForEach-Object {
                    $item=$_
                    switch ($item.Extension)
                    {
                        '.pfx' {
                            Import-PfxCertificate -FilePath $item.FullName -CertStoreLocation  "cert:\localMachine\my" -Password ($Using:PfxPassword) -Exportable | Out-Null
                        }
                        '.cer' {
                            if($item.Name.StartsWith("01"))
                            {
                                Import-Certificate -FilePath $item.FullName -CertStoreLocation "cert:\localMachine\my" | Out-Null
                            }
                            else
                            {
                                Import-Certificate -FilePath $item.FullName -CertStoreLocation "cert:\localMachine\root" | Out-Null
                            }
                        }
                    }
                }
            }
            finally
            {
                if(Test-Path $importPath)
                {
                    Remove-Item $importPath -Recurse -Force
                }
            }
        }

        Invoke-Command -Session $session -ScriptBlock $importBlock

    }
    finally
    {
        if($exportPath -and (Test-Path $exportPath))
        {
            Remove-Item $exportPath -Recurse -Force
        }
        if($ComputerName -and $Session)
        {
            $Session|Remove-PSSession
        }
    }


}
