function Get-RemoteRegistryProgram
{
  <#
    .Synopsis
      Uses remote registry to read installed programs
    .DESCRIPTION
      Use dot net and the registry key class to query installed programs from a 
      remote machine
    .EXAMPLE
      Get-RemoteRegistryProgram -ComputerName Server1
  #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=0)]
        [string[]]
        $ComputerName = $env:COMPUTERNAME
    )
    begin
    {
        $hives = @(
            [Microsoft.Win32.RegistryHive]::LocalMachine,
            [Microsoft.Win32.RegistryHive]::CurrentUser
        )

        $nodes = @(
            "Software\Microsoft\Windows\CurrentVersion\Uninstall",
            "Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
        )
    }
    process
    {
        forEach ($computer in $ComputerName)
        {
            forEach($hive in $hives)
            {
                try
                {
                    $registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($hive,$computer)
                }
                catch
                {
                    throw $PsItem
                }
                forEach($node in $nodes)
                {
                    try 
                    {
                        $keys = $registry.OpenSubKey($node).GetSubKeyNames()
                        forEach($key in $keys)
                        {
                            $displayname = $registry.OpenSubKey($node).OpenSubKey($key).GetValue('DisplayName')
                            if($displayname)
                            {
                                $installedProgram = @{
                                    DisplayName = $displayname
                                    Version = $registry.OpenSubKey($node).OpenSubKey($key).GetValue('DisplayVersion')
                                }
                                New-Object -TypeName PSObject -Property $installedProgram
                            }
                        }
                    }
                    catch
                    {
                        $orginalError = $PsItem
                        Switch($orginalError.FullyQualifiedErrorId)
                        {
                            'InvokeMethodOnNull' {
                                #key maynot exists
                            }
                            default {throw $orginalError }
                        }
                    }
                    
                }

            }
        }
    }
    end
    {

    }
}
