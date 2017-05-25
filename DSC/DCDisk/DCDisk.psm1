[DscResource()]
class DriveLabel
{
    [DscProperty(Key)]
    [string]
    $DriveLetter

    [DscProperty(Mandatory)]
    [string]
    $Label

    [DscProperty(NotConfigurable)]
    [string]
    $FileSystemType

    [DriveLabel]Get()
    {
        $this.DriveLetter
        $volumeInfo = Get-Volume -DriveLetter $this.DriveLetter
        $this.Label = $volumeInfo.FileSystemLabel
        $this.FileSystemType = $volumeInfo.FileSystem
        return $this
    }

    [bool]Test()
    {
        $labelCorrect = Get-Volume -DriveLetter $this.DriveLetter |
            Where-Object -FilterScript {$PSItem.FileSystemLabel -eq $this.Label}
        
        if($labelCorrect)
        {
            return $true
        }
        else
        {
            return $false
        }
    }

    [void]Set()
    {
        Write-Verbose -Message "Adding label [$($this.Label)] to [$($this.DriveLetter)] Drive"
        Get-Volume -DriveLetter $this.DriveLetter  |
            Set-Volume -NewFileSystemLabel $this.Label
    }
}