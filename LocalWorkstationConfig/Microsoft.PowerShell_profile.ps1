Function Start-ElevatedProcess
{
    <#
    .SYNOPSIS
    Runs a process / command as admin.

    .DESCRIPTION
    Runs a process with elevated privileges. Has the ability to open a new 
    powershell window. Can run legacy programs as admin cmd.

    .PARAMETER  Command
    Optional script block to execture. Can be argument for legacy cmd.

    .PARAMETER  Program
    Optional application to elevate. Default value = Powershell.exe

    .PARAMETER  Last
    Option Switch. Run previous powershell command as admin.
        
    .PARAMETER  NoExit
    Option Switch. Leave the eveleated powershell window open.

    .PARAMETER  Script
    Opional path to script file.

    .EXAMPLE
    ps c:\> Start-ElevatedProcess

    Opens a new powershell window with administrative privileges.

    .EXAMPLE
    ps c:\> Start-ElevatedProcess -Last -NoExit

    Runs the alst powershell command with adminsitrative privileges.

    .EXAMPLE
    ps c:\> Start-ElevatedProcess {ps iexplore | kill}

    Opens a new powershell window with administrative privileges stops 
    all internet explorer process.

    .EXAMPLE
    ps c:\> Start-ElevatedProcess -Program notepad -Command {C:\Windows\System32\Drivers\etc\hosts}

    Opens the host file as admin in notepad.exe.

    .INPUTS
    System.Management.Automation.ScriptBlock,System.String

    .OUTPUTS
    $null

    .NOTES
    Created by:   David Christian 

    .LINK
    http://www.opscripting.com/

#>

    [CmdletBinding(DefaultParameterSetName = 'Manual')]
    param(
        [Parameter(ParameterSetName = 'Manual', Position = 0)]
        [System.Management.Automation.ScriptBlock]
        $Command,

        [Parameter(ParameterSetName = 'Manual', Position = 1)]
        [System.String]
        $Program = (Join-Path -Path $PsHome -ChildPath 'powershell.exe'),

        [Parameter(ParameterSetName = 'History')]
        [Switch]
        $Last,

        [Parameter(ParameterSetName = 'History')]
        [Parameter(ParameterSetName = 'Manual')]
        [Parameter(ParameterSetName = 'Script')]
        [Switch]
        $NoExit,

        [Parameter(ParameterSetName = 'Script')]
        [ValidateScript( 
            {
                if (Test-Path -Path $_ -PathType Leaf)
                {
                    $true
                }
                else
                {
                    Throw "$_ is not a valid Path"
                }
            }
        )]
        [System.String]
        $Script
    )

    #Base parameters for the start-process cmdlet
    $startArgs = @{
        FilePath = $Program
        Verb = 'RunAs'
        ErrorAction = 'Stop'
    }

    if ($last)
    {
        $LastCommand = Get-History | 
            Select-Object -ExpandProperty CommandLine -Last 1
        $ArgList = "-command $lastCommand"
    }
    elseif ($command -and ($program -match 'powershell.exe$'))
    {
        $ArgList = "-command $command"
    }
    elseif ($script)
    {
        $script = Resolve-Path -Path $script
        $ArgList = "-file $script"
    }
    elseif ($Command)
    {
        $ArgList = "$command"
    }

    if ($NoExit -and $program -match 'powershell.exe$')
    {
        $ArgList = '-NoExit', $ArgList -join " "
    }

    if ($ArgList)
    {
        Write-Verbose -Message "Final command line: $ArgList"
        $startArgs.Add('ArgumentList', $ArgList)
    } 

    try
    {
        Start-Process @StartArgs 
    }
    catch
    {
        Write-Warning -Message (
            "Error starting process. Error Message: {0}" -f $_.Exception.Message)
    }

}

New-Alias -Name sudo -Value Start-ElevatedProcess
