[DscResource()]
class DriveLabel
{
    [string]
    $DriveLetter

    [string]
    $Label

    [DriveLabel]Get()
    {
        $this.DriveLetter
        $currentLabel = (Get-Volume -DriveLetter $this.DriveLetter).FileSystemLabel
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
        Get-Volume -DriveLetter $this.DriveLetter  |
            Set-Volume -NewFileSystemLabel $this.Label
    }
}