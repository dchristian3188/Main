$folder = '\\dcnas\Movies\Paranormal Activity'
$directories = Get-ChildItem -Path $folder

function Format-MovieName
{
    param(
        [string]
        $Name
    )

    $name = $name -Replace '\.',' '
    $name = $name -Replace 'dvdrip',''
    $name = $name -Replace 'xvid',''
    $name = $Name.Trim()
    #$name = $name -replace '(.*) (\d+$)','$1 ($2)'
    #$name = $name -replace '\d+ \- ',''
    $Name
}

foreach($dir in $directories)
{
    $newName = Format-MovieName -Name $dir.FullName 
    Move-Item -Path $dir.FullName -Destination $newName -Verbose -ErrorAction 0
}

