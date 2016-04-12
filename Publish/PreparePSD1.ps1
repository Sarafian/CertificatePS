& "$PSScriptRoot\..\ISEScripts\Reset-Module.ps1"

$exportedNames=Get-Command -Module CertificatePS | Select-Object -ExcludeProperty Name

. "$PSScriptRoot\Version.ps1"
$semVersion=Get-Version

$author="Alex Sarafian"
$company=""
$copyright="(c) $($date.Year) $company. All rights reserved."
$description="A module to help render Markdown from powershell"

$modules=Get-ChildItem "$PSScriptRoot\..\Modules\"

foreach($module in $modules)
{
    Write-Host "Processing $module"
    $name=$module.Name

    $psm1Name=$name+".psm1"
    $psd1Name=$name+".psd1"
    $psd1Path=Join-Path $module.FullName $psd1Name

    $guid="c1e7cbac-9e47-4906-8281-5f16471d7ccd"
    $hash=@{
        "Author"=$author;
        "Copyright"=$cop;
        "RootModule"=$psm1Name;
        "Description"=$description;
        "Guid"=$guid;
        "ModuleVersion"=$semVersion;
        "Path"=$psd1Path;
        "Tags"=@('Markdown', 'Tools');
        "LicenseUri"='https://github.com/Sarafian/CertificatePS/blob/master/LICENSE';
        "ProjectUri"= 'https://github.com/Sarafian/CertificatePS/';
        "IconUri" ='https://cdn0.iconfinder.com/data/icons/fatcow/32x32/ssl_certificates.png';
        "ReleaseNotes"= 'https://github.com/Sarafian/CertificatePS/blob/master/CHANGELOG.md';
        "CmdletsToExport" = $exportedNames;
        "FunctionsToExport" = $exportedNames
    }

    New-ModuleManifest  @hash 
}


