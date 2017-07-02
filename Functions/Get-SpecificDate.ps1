function Get-SpecificDate
{

    <#
    .SYNOPSIS
        Finds a specific instance of the day of the week.
    .DESCRIPTION
        This function can be used to find an instance of a day of the week.
        For example, you can ask for the first Monday of the month.
    .PARAMETER Instance
        Which week day instance to return for selected month.
        Valid options are: First, Second, Third, Fourth, Fifth, Last
    .PARAMETER Day
        Day of week to return. Options should be DayOfWeek type.
    .PARAMETER Month
        Which month to select. Value should be between 1 and 12.
        Defaults to current month.
    .PARAMETER Year
        Whcih year to select. Default value is current year.
    .EXAMPLE
        PS C:\> Get-SpecifcDay -Instance Second -Day Tuesday
        Returns a DateTime object representing the second Tuesday of the 
        current month
    .EXAMPLE
        PS C:\> 1..12 | Get-SpecificDate Second Tuesday
        Lists all patch Tuesdays for the current year.
    .OUTPUTS
        DateTime
    .Link
        overpowershell.com
    #>

    [CmdletBinding()]
    [OutputType([DateTime])]
    Param
    (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidateSet("First", "Second", "Third", "Fourth", "Fifth", "Last")]
        [string]
        $Instance,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [DayOfWeek]
        $Day,

        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [ValidateRange(1, 12)]
        [int]
        $Month = (Get-Date).Month,

        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        [ValidateNotNullOrEmpty()]
        [int]
        $Year = (Get-Date).Year
    )
    Process
    {
        [datetime]$tempDate = "{0}/{1}/{2}" -f $Year, $Month, 1
        while ($tempDate.DayOfWeek -ne $Day)
        {
            $tempDate = $tempDate.AddDays(1) 
        }
    
        if ($Instance -eq 'Last')
        {
            $longMonth = $tempDate.AddDays(28).Month -eq $Month
            if ($longMonth)
            {
                $finalDate = $tempDate.AddDays(28)
            }
            else 
            {
                $finalDate = $tempDate.AddDays(21)    
            }
        }
        else
        {
            $increment = switch ($Instance)
            {
                'First' {0}
                'Second' {7}
                'Third' {14}
                'Fourth' {21}
                'Fifth' {28}
            }
            $finalDate = $tempDate.AddDays($increment)    
        }
    
        if ($finalDate.Month -gt $Month)
        {
            $monthFriendlyName = [Globalization.DateTimeFormatInfo]::CurrentInfo.GetMonthName($Month)
            $message = ("There is no {0} {1} in {2} ({3})" -f $Instance, $Day, $monthFriendlyName, $Year)
            throw [IndexOutOfRangeException]::New($message)
        }
        Else
        {
            $finalDate
        }
    }
}