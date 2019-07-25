Function Get-Mode {
    param(
        [switch]
        $AllNotes
    )

    if ($AllNotes) {
        $notes = @(
            'A'
            'A#'
            'B'
            'C'
            'C#'
            'D'
            'D#'
            'E'
            'F'
            'F#'
            'G'
            'G#'
        )
    }
    else {
        $notes = @(
            'A'
            'B'
            'C'
            'D'
            'E'
            'F'
            'G'
        )
    }
    

    $Modes = @(
        'Ionian'
        'Dorian'
        'Phrygian'
        'Lydian'
        'Mixolydian'
        'Aeolian'
        'Locrian'
    )

    $note = $notes | Get-Random
    $mode = $modes | Get-Random
    Write-Output -InputObject "$note $mode"
}
