function Remove-SubDirectory
{
    <#
    .Synopsis
      Short description
    .DESCRIPTION
      Long description
    .EXAMPLE
      Example of how to use this cmdlet
  #>
    [CmdletBinding(DefaultParameterSetName = 'Parameter Set 1', 
        SupportsShouldProcess = $true, 
        PositionalBinding = $false,
        HelpUri = 'http://www.microsoft.com/',
        ConfirmImpact = 'Medium')]
    Param
    (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $Path
    )
    begin
    {

    }
    process
    {
        foreach ($directory in $Path)
        {

        }

    }
    end
    {

    }
}