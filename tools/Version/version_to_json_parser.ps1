Param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

$file = [System.IO.File]::ReadAllText($FilePath)

$name = [RegEx]::Match($file,"\nName\s=\s(.*)").Captures.Groups[1].Value.Trim()
$productVersion = [RegEx]::Match($file,"\nProductVersion\s=\s(.*)").Captures.Groups[1].Value.Trim()
$url = [RegEx]::Match($file,"\nURL\s=\s(.*)").Captures.Groups[1].Value.Trim()
$size = [RegEx]::Match($file,"\nSize\s=\s(.*)").Captures.Groups[1].Value.Trim()
$md5 = [RegEx]::Match($file,"\nMD5\s=\s(.*)").Captures.Groups[1].Value.Trim()
$serverFileName = [RegEx]::Match($file,"\nServerFileName\s=\s(.*)").Captures.Groups[1].Value.Trim()
$flags = [RegEx]::Match($file,"\nFlags\s=\s(.*)").Captures.Groups[1].Value.Trim()
$version = [RegEx]::Match($file,"\nVersion\s=\s(.*)").Captures.Groups[1].Value.Trim()

$json = "{
    ""description"":""$name"",
    ""download_url"":""$url"",
    ""setup_url"":""$url"",
    ""product_version"":""$productVersion"",
    ""size"":""$size"",
    ""md5"":""$md5"",
    ""server_file_name"":""$serverFileName"",
    ""flags"":""$flags"",
    ""version"":""$version"" 
}"

$destinationFolder = [System.IO.Path]::GetDirectoryName($FilePath)
$jsonFilePath = [System.IO.Path]::Combine($destinationFolder, "version.json")

[System.IO.File]::WriteAllText($jsonFilePath, $json)





