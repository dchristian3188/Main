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
        if (-not  (Test-Path -LiteralPath $HandbrakePath))
        {
            Write-Error -Message "Unable to find Handbrake at path [$HandbrakePath]" -ErrorAction Stop
        }
    }
    process
    {
        foreach ($file in $Path)
        {
            Write-Verbose -Message "Starting on file $file"
            if (-not(Test-Path -LiteralPath $file))
            {
                Write-Warning -Message "Unable to find file at path [$file]"
                continue  
            }
            
            $source = (Resolve-Path -LiteralPath $file).ProviderPath
            $dest = [IO.Path]::ChangeExtension($source, ".$($OutputFormat)")
            if ($source -eq $dest)
            {
                $LASTEXITCODE = 1
                Write-Warning -Message "Skipping source and destination are same."
            }
            else
            {
                $procArgs = '-i "{0}" -o "{1}" -Z "{2}" -f av_{3}' -f $source, $dest, $HandbrakePreset, $OutputFormat
                Write-Verbose -Message "Running Handbrake with paramrs $($procArgs)"
                Start-Process -FilePath $HandbrakePath -ArgumentList $procArgs -Wait -WindowStyle Minimized
            }
            
            [pscustomobject]@{
                Source       = $source
                Destination  = $dest
                LastExitCode = $LASTEXITCODE
            }
        }
    }
    end
    {
        $LASTEXITCODE = 0
    }
}

Function Start-FFMpeg
{
    [cmdletbinding()]
    Param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('FullName')]
        [string[]]
        $Path,

        [Parameter()]
        [string]
        $ffmpegPath = 'C:\Program Files\FFMpeg\ffmpeg.exe',

        [Parameter()]
        [string]
        $OutputFormat = 'mkv'

    )
    begin
    {
        if (-not  (Test-Path -LiteralPath $ffmpegPath))
        {
            Write-Error -Message "Unable to find Handbrake at path [$ffmpegPath]" -ErrorAction Stop
        }
    }
    process
    {
        foreach ($file in $Path)
        {
            Write-Verbose -Message "Starting on file $file"
            if (-not(Test-Path -LiteralPath $file))
            {
                Write-Warning -Message "Unable to find file at path [$file]"
                continue  
            }
            
            $source = (Resolve-Path -LiteralPath $file).ProviderPath
            $dest = [IO.Path]::ChangeExtension($source, ".$($OutputFormat)")
            if ($source -eq $dest)
            {
                $LASTEXITCODE = 1
                Write-Warning -Message "Skipping source and destination are same."
            }
            else
            {
                $procArgs = '-y -i "{0}" "{1}"' -f $source, $dest
                Write-Verbose -Message "Running ffmpeg with paramrs $($procArgs)"
                Start-Process -FilePath $ffmpegPath -ArgumentList $procArgs -Wait -WindowStyle Minimized
            }
            
            [pscustomobject]@{
                Source       = $source
                Destination  = $dest
                LastExitCode = $LASTEXITCODE
            }
        }
    }
    end
    {
        $LASTEXITCODE = 0
    }
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


Function Convert-Files
{
    [cmdletbinding()]
    Param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]]
        $Path

    )
    begin {}
    process
    {
        foreach ($file in $Path)
        {
            $LASTEXITCODE = 0
            $isWindowsMediaFile = ([io.path]::GetExtension($file)).ToLower() -eq '.wmv'
            if($isWindowsMediaFile)
            {
                $hb = Start-FFMpeg -Path $file -Verbose
            }
            else {
                $hb = Start-Handbrake -Path $file -Verbose
            }
            $hb | FL *
            if ($hb.LastExitCode -ne 0)
            {
                Write-Warning -Message "Filename [$file], last exit code not 0, [$($hb.LastExitCode)]"
                continue
            }

            if (-not(Test-Path -LiteralPath $hb.Destination))
            {
                Write-Warning -Message "Destination not found at [$($hb.Destination)]"
                continue
            }
            $orginalVideoLength = Get-VideoLength -FilePath $hb.Source
            $newVideoLength = Get-VideoLength -FilePath $hb.Destination
            try
            {
                $timeDifference = New-TimeSpan -Start $newVideoLength -End $orginalVideoLength -ErrorAction Stop
            }
            catch
            {
                Write-Warning -Message "Unable to compare Video lengths... Exiting"
                continue
            }
            if ([math]::Abs($timeDifference.TotalSeconds) -gt 30)
            {
                Write-Warning -Message "Time duration doesnt match. Orginal [$orginalVideoLength] New [$newVideoLength]"
                continue
            }
        
            $orginalSize = (Get-ChildItem -Path $hb.Source).Length
            $newSize = (Get-ChildItem -Path $hb.Destination).Length
        
            Write-Verbose -Message ("Old Size [{0:N2}mb], new size [{1:N2}mb]" -f ($orginalSize / 1mb), ($newSize / 1mb))
            $newFileSmaller = ($newSize -lt $orginalSize) -and ($newSize -gt 0)
            if ($newFileSmaller)
            {
                Write-Verbose -Message "Orginal File is larger, removing"
                Remove-Item -Path $hb.Source
            }
            else
            {
                Write-Verbose -Message "New File is larger, removing"
                Remove-Item -Path $hb.Destination
                Move-Item -Path $hb.Source -Destination "$($hb.Source).mkv"
            }
        }
    }
    end {}        
}

$files = Get-ChildItem -File -Rec | ? extension -notmatch 'mkv' | sort length -desc 
Foreach($file in $files)
{
    Convert-Files -Path $file.FullName -Verbose *>> C:\temp\logger.txt
    #Start-Sleep -Seconds 300
}