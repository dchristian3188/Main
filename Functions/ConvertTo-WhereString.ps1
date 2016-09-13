Function ConvertTo-WhereString
{
    <#
    .Synopsis
       Converts a hashtable to a where script block.
    .DESCRIPTION
       Converts hashtable to filter script block. Useful
       for creating where filters when not all properties
       are known. 
    .PARAMETER InputObject
        Object to be converted
    .EXAMPLE
       
       $whereScript = Get-Service -Name Spooler |
            Select-Object Status,StartType,CanPauseAndContinue | 
            ConvertTo-HashTable | 
            ConvertTo-WhereString
       
       Get-Service |
        Where-Object $whereScript
      
       Displays all services currenlty matching the Status, StartType and 
       CanPauseAndContinue properties of the spooler service.

    .NOTES
        Created by David Christian
    .Link
        https://github.com/dchristian3188
    #>

    [CmdletBinding()]
    [OutputType([ScriptBlock])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true, 
                   ValueFromPipelineByPropertyName=$true, 
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [HashTable]
        $InputHash
    )
    Begin
    {
    }
    Process
    {
        $raw = ForEach($property in $InputHash.Keys)
        {
            Write-Output -InputObject ('($_.{0} -eq "{1}")' -f $property,$InputHash[$property])
        }

        $whereFilter = $raw -join " -and "
        Return [ScriptBlock]::Create($whereFilter)
    }
    End
    {
    }
}