$handbrakePath = 'C:\Program Files\HandBrake\HandBrakeCLI.exe'

Foreach($file in $files)
$source = "E:\folder\somepath\filename.wmv"
$dest = "E:\folder\somepath\filename.mkv"

$procArgs = '-i "{0}" -o "{1}" -Z "Very Fast 576p25" -f av_mkv' -f $source,$dest

$results = Start-Process -FilePath $handbrakePath -ArgumentList $procArgs -NoNewWindow -Wait -PassThru



Function Get-VideoLength($FilePath)
{
    $Folder = Split-Path -Path $FilePath
    $File = Split-Path -Path $FilePath -Leaf
    $LengthColumn = 27
    $objShell = New-Object -ComObject Shell.Application 
    $objFolder = $objShell.Namespace($Folder)
    $objFile = $objFolder.ParseName($File)
    $Length = $objFolder.GetDetailsOf($objFile, $LengthColumn)
    $Length
}
