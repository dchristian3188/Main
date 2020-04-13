Function Add-DirName 
{
    param(
        [string]
        $Directory
    )

    $directoryInfo = Get-Item -Path $Directory
    if(!$directoryInfo.PSIsContainer)
    {
        Write-Warning -Message "$Directory is not a directory "
        return
    }

    $files = Get-ChildItem -Path $Directory
    $directoryName = Split-Path -LeafBase $Directory
    foreach($file in $files)
    {
        $newFileName = "{0}\{1}-{2}" -f $Directory,$directoryName, (Split-Path -Path $file -Leaf)
        Move-Item -Path $file -Destination $newFileName -Verbose
    }
}

Add-DirName -Directory 