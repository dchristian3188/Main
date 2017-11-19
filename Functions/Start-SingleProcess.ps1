function Start-SingleProcess
{
    <#
    .Synopsis
      Short description
    .DESCRIPTION
      Long description
    .EXAMPLE
      Example of how to use this cmdlet
  #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName)]
        [string[]]
        $ProcessPath
    )

    begin
    {

    }
    process
    {
        foreach ($path in $ProcessPath)
        {
            if (-not(Test-Path -Path $path))
            {
                Write-Warning -Message "Unable to find executable at [$path]"
                continue
            }

            $processName = (Get-ChildItem -Path $path).BaseName
            try
            {
                Get-Process -Name $processName -ErrorAction Stop > $null
                Write-Verbose -Message "$processName is already running"
            }
            catch
            {
                if ($PSItem.FullyQualifiedErrorId -eq 'NoProcessFoundForGivenName,Microsoft.PowerShell.Commands.GetProcessCommand')
                {
                    Start-Process -FilePath $path
                }
                else
                {
                    throw $PSItem
                }
            }
        }
    }
    end
    {

    }
}

@(
  "C:\Windows\System32\notepad.exe"
  "C:\Program Files\Microsoft VS Code\Code.exe"
  "C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe"
)  | Start-SingleProcess -Verbose