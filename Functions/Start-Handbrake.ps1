Function Start-Handbrake
{
    [cmdletbinding()]
    Param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]]
        $Path,

        [Parameter()]
        [string]
        $HandbrakePath = 'C:\Program Files\HandBrake\HandBrakeCLI.exe',

        [Parameter()]
        [string]
        $HandbrakePreset = 'Very Fast 576p25',

        [Parameter()]
        [string]
        $OutputFormat = 'mkv'

    )
    begin
    {
        if (-not  (Test-Path -Path $HandbrakePath))
        {
            #Write-Error -Message "Unable to find Handbrake at path [$HandbrakePath]" -ErrorAction Stop
        }
    }
    process
    {
        foreach ($file in $Path)
        {
            if (-not(Test-Path -Path $file))
            {
                Write-Warning -Message "Unable to find file at path [$file]"
                continue  
            }
            
            $source = (Resolve-Path -Path $file).ProviderPath
            $dest = [IO.Path]::ChangeExtension($source, ".$($OutputFormat)")
            
            $procArgs = '-i "{0}" -o "{1}" -Z "{2}" -f av_{3}' -f $source, $dest, $HandbrakePreset, $OutputFormat
            $procargs
            #Start-Process -FilePath $HandbrakePath -ArgumentList $procArgs
            [pscustomobject]@{
                Source       = $source
                Destination  = $dest
                LastExitCode = $LASTEXITCODE
            }
        }
    }
    end {}
}


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

Function Write-Warning($Message)
{
    Write-Warning -Message $Message
}

$files = "somefiles"
foreach ($file in $files)
{
    $hb = Start-Handbrake -Path $file 
    if ($hb.LastExitCode -ne 0)
    {
        Write-Warning -Message "Filename [$file], last exit code not 0, [$($hb.LastExitCode)]"
        continue
    }
    $orginalVideoLength = Get-VideoLength -FilePath $hb.Source
    $newVideoLength = Get-VideoLength -FilePath $hb.Destination
    $timeDifference = New-TimeSpan -Start $newVideoLength -End $orginalVideoLength
    if ([math]::Abs($timeDifference.TotalSeconds) -gt 4)
    {
        Write-Warning -Message "Time duration doesnt match. Orginal [$orginalVideoLength] New [$newVideoLength]"
        continue
    }

    $orginalSize = (Get-ChildItem -Path $hb.Source).Length
    $newSize = (Get-ChildItem -Path $hb.Destination).Length

    $newFileSmaller = $newSize -lt $orginalSize
    if ($newFileSmaller)
    {
        Write-Verbose -Message "Orginal File is larger, removing"
        Remove-Item -Path $hb.Source
    }
    else
    {
        Write-Verbose -Message "New File is larger, removing"
        Remove-Item -Path $hb.Destination
    }
}
