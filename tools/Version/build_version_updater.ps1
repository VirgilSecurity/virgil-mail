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

$foundVersion = [RegEx]::Match($contents, "AssemblyFileVersion\(""(?<ver>\d+\.\d+\.\d+\.\d+)""\)").Groups["ver"].Value

$version = [System.Version]::Parse($foundVersion)
$versionString = [System.String]::Format("{0}.{1}.{2}.{3}", $version.Major, $version.Minor, $BuildNumber, 0)

 
$contents = [RegEx]::Replace($contents, "AssemblyVersion\(""(?<ver>\d+\.\d+\.\d+\.\d+)""\)", "AssemblyVersion(""" + $versionString + """)")
$contents = [RegEx]::Replace($contents, "AssemblyFileVersion\(""(?<ver>\d+\.\d+\.\d+\.\d+)""\)", "AssemblyFileVersion(""" + $versionString + """)")

[System.IO.File]::WriteAllText($assemblyInfoPath, $contents)