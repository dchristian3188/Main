$extensions = @(
    '.bup'
    '.nfo'
    '.ifo'
    '.gif'
    '.jpeg'
    '.jpg'
    '.log'
    '.mds'
    '.png'
    '.sfv'
    '.rar'
    '.torrent'
    '.txt'
    '.xml'
    '.zip'
)

Get-ChildItem -Recurse -Directory | 
    ? name -eq '.unwanted' | 
    Remove-Item -Recurse -Verbose -Force

    
Get-ChildItem  -Recurse -File | 
    Where-Object {$PSitem.Extension -in $extensions} | 
    Remove-Item -Verbose -Force

$dirs = Get-ChildItem -Directory
foreach($dir in $dirs)
{
    $files = Get-ChildItem -File -Path $dir
    if($files.Count -eq 1)
    {
        Move-Item -Path $files.FullName -Destination . -Verbose -Force
    }
}
Robocopy.exe D:\Programdata D:\Programdata /S /MOVE    