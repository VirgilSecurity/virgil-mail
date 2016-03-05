Param (    
    [Parameter(Mandatory=$true)]
	[string]$FilePath,
    [Parameter(Mandatory=$true)]
    [string]$BuildNumber
)

#
# This script will increment the build number in an AssemblyInfo.cs file
#

$assemblyInfoPath = $FilePath

$contents = [System.IO.File]::ReadAllText($assemblyInfoPath)

$versionString = [RegEx]::Match($contents,"(AssemblyFileVersion\("")(?:\d+\.\d+\.\d+\.\d+)(""\))")

$currentBuild = [RegEx]::Match($versionString,"(\.)(\d+)(""\))").Groups[2]

$contents = [RegEx]::Replace($contents, "(AssemblyVersion\(""\d+\.\d+\.\d+\.)(?:\d+)(""\))", ("`${1}" + $BuildNumber + "`${2}"))
$contents = [RegEx]::Replace($contents, "(AssemblyFileVersion\(""\d+\.\d+\.\d+\.)(?:\d+)(""\))", ("`${1}" + $BuildNumber + "`${2}"))

[System.IO.File]::WriteAllText($assemblyInfoPath, $contents)