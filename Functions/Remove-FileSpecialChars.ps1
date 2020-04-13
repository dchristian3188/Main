function Remove-FileSpecialChars
{
  <#
    .Synopsis
      Short description
    .DESCRIPTION
      Long description
    .EXAMPLE
      Example of how to use this cmdlet
  #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param
    (
      # Specifies a path to one or more locations. Wildcards are permitted.
      [Parameter(Mandatory=$true,
                 Position=0,
                 ValueFromPipeline=$true,
                 ValueFromPipelineByPropertyName=$true,
                 HelpMessage="Path to one or more locations.")]
      [ValidateNotNullOrEmpty()]
      [Alias('FullName')]
      [string[]]
      $Path

    )
    begin
    {
        $specialCharRegex =  '[^a-zA-Z0-9 :\\$\.\-]'

    }
    process
    {
        foreach($fPath in $Path)
        {

            $newName = ($fPath -replace $specialCharRegex,'') -replace '\s\s+',' '
            if($newName -ne $fPath)
            {
              Move-Item -LiteralPath $fPath -Destination $newName -Verbose -Force
            }

            $newName = ($fpath.Replace('-','')) -replace '\s\s+',' '
            if($newName -ne $fPath)
            {
              Move-Item -LiteralPath $fPath -Destination $newName -Verbose -Force
            }
        }
    }
    end
    {

    }
}


dir -Recurse -Directory | 
  Remove-FileSpecialChars -Verbose

  
dir -Recurse -File | 
Remove-FileSpecialChars -Verbose