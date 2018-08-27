$extensions = @(
    '.bup'
    '.ifo'
    '.jpeg'
    '.jpg'
    '.mds'
    '.png'
    '.rar'
    '.txt'
    '.zip'
)

Get-ChildItem  -Recurse -File | 
    Where-Object {$PSitem.Extension -in $extensions} | 
    Remove-Item -Verbose -Force