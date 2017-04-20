function Open-PSCommandHelp
{
    <#
    .SYNOPSIS
    Opens a random help file.

    .DESCRIPTION
    Opens a help file of a PowerShell cmdlet. 

    .PARAMETER  Module
    Optional Parameter. The module the command will come from.

    .PARAMETER  Verb
    Optional Parameter. The verb of the command to chose.

    .PARAMETER  Noun
    Optional Parameter. The Noun of the command to chose.

    .EXAMPLE
    PS C:\>Open-PSCommandHelp

    This example will open a help file for a random cmdlet.

    .EXAMPLE
    PS C:\> Open-PSCommandHelp -Module ActiveDirectory

    This example will open a random help file for an Active Directory cmdlet.

    .NOTES

    Created by:   David Christian

    .LINK
    https://github.com/dchristian3188
    http://overpoweredshell.com/
#>
    
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [System.String]
        $Module,
        
        [Parameter(Position = 1)]
        [System.String]
        $Verb,
        
        [Parameter(Position = 2)]
        [System.String]
        $Noun
    )
    
    $Command = Get-Command @PSBoundParameters | 
        Get-Random -Count 1
    
    if ($Command)
    {
        $tempDir = [System.io.Path]::GetTempPath()
        $filePath = Join-Path -Path $tempDir -ChildPath ("{0}.txt" -f $Command.Name)
        
        try
        {
            Get-Help -Name $Command.Name -Full -ErrorAction 'Stop' | 
                Out-File -FilePath $filePath
            Invoke-Item -Path $filePath -ErrorAction Stop
        }Catch
        {
            Write-Warning -Message ("Unable to open Help file. {0}" -f $_.Exception.Message)
        }
    }
    else
    {
        $criteria = foreach ($parameter in $PSBoundParameters.Keys)
        {
            Write-Output -InputObject ("{0} = {1}" -f $parameter, $PSBoundParameters[$parameter])
        }
        
        $criteria = $criteria -join ", "
        Write-Warning -Message "No commands meet criteria: $criteria"
    }
}
