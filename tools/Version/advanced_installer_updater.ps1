Param (    
    [Parameter(Mandatory=$true)]
    [string]$TemplateFilePath,
    [Parameter(Mandatory=$true)]
    [string]$AssemblyInfoFilePath,
    [Parameter(Mandatory=$true)]
    [string]$ResultFilePath
)

$AssemblyInfoContent = [System.IO.File]::ReadAllText($AssemblyInfoFilePath)
$TemplateContant = [System.IO.File]::ReadAllText($TemplateFilePath)

$versionString = [RegEx]::Match($AssemblyInfoContent,"(AssemblyFileVersion\("")(?:\d+\.\d+\.\d+\.\d+)(""\))")
$versionString = [RegEx]::Match($versionString,"(?:\d+\.\d+\.\d+\.\d+)")

$ResultContent = [RegEx]::Replace($TemplateContant, "%VERSION%", $versionString)

[System.IO.File]::WriteAllText($ResultFilePath, $ResultContent)