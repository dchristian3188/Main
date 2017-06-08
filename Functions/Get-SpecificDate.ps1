function Get-SpecificDate
{
    [CmdletBinding()]
    [OutputType([System.DateTime])]
    Param
    (
        
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateSet("First", "Second", "Third","Fourth","Fifth")]
        [System.String]
        $Instance,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [System.DayOfWeek]
        $Day,

        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateRange(1,12)]
        [int]
        $Month = (Get-Date).Month,

        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [int]
        $Year = (Get-Date).Year

    )

    [System.DateTime]$TempDate = "{0}/{1}/{2}" -f $Year,$Month,1
    
    While($TempDate.DayOfWeek -ne $Day){
        $TempDate = $TempDate.AddDays(1) 
    }

    
    $increment = switch ($Instance)
    {
        'First' {0}
        'Second' {7}
        'Third' {14}
        'Fourth' {21}
        'Fifth' {28}
    }

    $finalDate = $TempDate.AddDays($increment)
    if($finalDate.Month -gt $Month){
        Write-Warning -Message ("There is no {0} {1} in {2} ({3})" -f $Instance,$Day,[System.Globalization.DateTimeFormatInfo]::CurrentInfo.GetMonthName($Month),$Year)
    }Else{
        $finalDate
    }
}


$day = Get-SpecificDate -Instance fourth -Day tuesday
$day
