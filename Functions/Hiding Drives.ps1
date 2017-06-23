Function Get-LetterMap
{
    $letterMap = @{}
    1..26 | ForEach-Object {
        $currentNumber = $_
        $letter = [char]($currentNumber + 64)
        $driveValue = [math]::Pow(2, ($currentNumber - 1))
        $letterMap[$letter] = $driveValue
    }
    $letterMap
}

Function Get-HiddenDrive
{
    $HIDDEN_DRIVES_KEY = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\'
    $hiddenDrives = (Get-Item -Path $HIDDEN_DRIVES_KEY).GetValue("NoDrives")

    $letterMap = Get-LetterMap
    foreach ($letter in $letterMap.Keys | Sort-Object)
    {
        $driveHidden = ($hiddenDrives -band $letterMap[$letter]) -eq $letterMap[$letter]
        If ($driveHidden)
        {
            $letter
        }
    }
}

Function Get-HiddenDrive
{
    $HIDDEN_DRIVES_KEY = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\'
    $hiddenDrives = (Get-Item -Path $HIDDEN_DRIVES_KEY).GetValue("NoDrives")
    ls > $NUl
    $letterMap = Get-LetterMap
    foreach ($letter in $letterMap.Keys | Sort-Object)
    {
        $driveHidden = ($hiddenDrives -band $letterMap[$letter]) -eq $letterMap[$letter]
        If ($driveHidden)
        {
            $letter
        }
    }
}
