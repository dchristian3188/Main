function Get-AvailableFileName
{
    <#
    .Synopsis
      Gets an avaialble file name
    .DESCRIPTION
      Test a path to see if it exists. If a file already exists, it 
      will append '(x)' to the file name, where x is the next available number.
    .EXAMPLE
      Get-AvailableFileName -Path C:\Temp\SomeFilePath.txt
  #>
    [CmdletBinding()]
    Param
    (
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Alias("PSPath", "FullName")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path
    )
    begin {}
    process
    {
        foreach ($newName in $Path)
        {
            if (Test-Path -Path $newName)
            {
                $folder = Split-Path -Path $newName -Parent
                $basename = [IO.Path]::GetFileNameWithoutExtension($newName)
                $extension = [IO.Path]::GetExtension($newName)
                $counter = 1
            }

            while (Test-Path -Path $newName)
            {
                $newName = "$($folder)\$($basename)($counter)$($extension)"
                $counter++  
            }
            Write-Output -InputObject $newName
        }
    }
    end {}
}
