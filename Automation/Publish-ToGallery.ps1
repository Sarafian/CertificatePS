﻿param(
    [Parameter(Mandatory=$false)]
    [string]$NuGetApiKey=$null
)
$repository="PSGallery"
$moduleName="CertificatePS"
$progressActivity="Publish $moduleName"

try
{
    $tempWorkFolderPath=Join-Path $env:TEMP "$moduleName-Publish"
    if(Test-Path $tempWorkFolderPath)
    {
        Remove-Item -Path $tempWorkFolderPath -Recurse -Force
    }
    New-Item -Path $tempWorkFolderPath -ItemType Directory|Out-Null
    Write-Verbose "Temporary working folder $tempWorkFolderPath is ready"

    $modulePath=Resolve-Path "$PSScriptRoot\..\Source\Modules\$moduleName"
    $psm1Path=Join-Path $modulePath "$moduleName.psm1"

    $sourcePsm1Content=Get-Content -Path $psm1Path -Raw
    $versionRegEx="\.VERSION (?<Major>([0-9]+))\.(?<Minor>([0-9]+))"
    if($sourcePsm1Content -notmatch $versionRegEx)
    {
        Write-Error "$psm1Path doesn't contain script info .VERSION"
        return -1
    }
    $sourceMajor=[int]$Matches["Major"]
    $sourceMinor=[int]$Matches["Minor"]
    $sourceVersion="$sourceMajor.$sourceMinor"

    Write-Debug "sourceMajor=$sourceMajor"
    Write-Debug "sourceMinor=$sourceMinor"

    #region query
    Write-Debug "Querying $moduleName"
    Write-Progress -Activity $progressActivity -Status "Querying..."
    $repositoryModule=Find-Module -Name $moduleName -Repository $repository -ErrorAction SilentlyContinue
    Write-Verbose "Queried $moduleName"
    $shouldTryPublish=$false

    if($repositoryModule)
    {
        $publishedVersion=$repositoryModule.Version
        $publishedMajor=$publishedVersion.Major
        $publishedMinor=$publishedVersion.Minor

        Write-Verbose "Found existing published module with version $publishedVersion"

        if(($sourceMajor -ne $publishedMajor) -or ($sourceMinor -ne $publishedMinor))
        {
            Write-Verbose "Source version $sourceMajor.$sourceMinor is different that published version $publishedVersion"
            $shouldTryPublish=$true
        }
        else
        {
            Write-Warning "Source version $sourceMajor.$sourceMinor is the same as with the already published. Will skip publishing"
        }
    }
    else
    {
        Write-Verbose "Module is not yet published to the $repository repository"
        $shouldTryPublish=$true
    }
    #endregion

    if($shouldTryPublish)
    {
        #region manifest
        Write-Debug "Generating manifest"
    
        Import-Module $psm1Path -Force 
        $exportedNames=Get-Command -Module $moduleName | Select-Object -ExcludeProperty Name

        $psm1Name=$moduleName+".psm1"
        $psd1Path=Join-Path $modulePath "$moduleName.psd1"
        $guid="c1e7cbac-9e47-4906-8281-5f16471d7ccd"
        $hash=@{
            "Author"="Alex Sarafian"
            "Copyright"="(c) 2016 Alex Sarafian. All rights reserved."
            "RootModule"=$psm1Name
            "Description"="A module to enhance certificate management"
            "Guid"=$guid
            "ModuleVersion"=$sourceVersion
            "Path"=$psd1Path
            "LicenseUri"='https://github.com/Sarafian/CertificatePS/blob/master/LICENSE'
            "ProjectUri"= 'https://github.com/Sarafian/CertificatePS/'
            "IconUri"= 'https://cdn0.iconfinder.com/data/icons/fatcow/32x32/ssl_certificates.png'
            "ReleaseNotes"= 'https://github.com/Sarafian/CertificatePS/blob/master/CHANGELOG.md'
            "CmdletsToExport" = $exportedNames
            "FunctionsToExport" = $exportedNames
        }

        New-ModuleManifest  @hash 

        Write-Verbose "Generated manifest"
        #endregion

        #region publish
        Write-Debug "Publishing $moduleName"
        Write-Progress -Activity $progressActivity -Status "Publishing..."
        if($NuGetApiKey)
        {
            Publish-Module -Repository $repository -Path $modulePath -NuGetApiKey $NuGetApiKey -Confirm:$false
        }
        else
        {
            Publish-Module -Repository $repository -Path $modulePath -NuGetApiKey "MockKey" -WhatIf -Confirm:$false
        }
        Write-Verbose "Published $moduleName"
        #endregion
    }
}
finally
{
    Write-Progress -Activity $progressActivity -Completed
}
