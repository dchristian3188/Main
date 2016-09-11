Function Start-ElevatedProcess {
<#
    .SYNOPSIS
        Runs a process / command as admin.
  
    .DESCRIPTION
        Runs a process with elevated privileges. Has the ability to open a new 
        PowerShell window. Can run legacy programs as admin cmd.
  
    .PARAMETER  Scriptblock
        Optional script block to execute. Can be used as an argument for legacy cmd.
  
    .PARAMETER  Application
        Optional application to elevate. Default value = Powershell.exe
        
    .PARAMETER  Last
        Option switch. Run previous PowerShell command as admin.
              
    .PARAMETER  NoExit
        Option Switch. Leave the elevated PowerShell window open.
  
    .PARAMETER  Script
        Optional path to script file.
        
    .EXAMPLE
        ps c:\> Start-ElevatedProcess
        
        Opens a new PowerShell window with administrative privileges.
          
    .EXAMPLE
        ps c:\> Start-ElevatedProcess -Last -NoExit
        
        Runs the last PowerShell command with administrative privileges.
      
    .EXAMPLE
        ps c:\> Start-ElevatedProcess {Get-Process iexplore | Stop-Process}
        
        Opens a new PowerShell window with administrative privileges stops 
        all internet explorer process.
      
    .EXAMPLE
        ps c:\> Start-ElevatedProcess -Application notepad -Scriptblock {C:\Windows\System32\Drivers\etc\hosts}
        
        Opens the host file as admin in notepad.exe.
  
    .INPUTS
        System.Management.Automation.ScriptBlock,System.String
  
    .OUTPUTS
        $null
  
    .NOTES
        Created by:   David Christian 
  
    .LINK
        https://github.com/dchristian3188 
#>

    [CmdletBinding(DefaultParameterSetName='Command')]
    Param
    (
        [Parameter(ParameterSetName='Command',
                    Position=0)]
        [System.Management.Automation.ScriptBlock]
        $Scriptblock,

        [Parameter(ParameterSetName='Command',
                    Position=1)]
        [System.String]
        $Application = (Join-Path -Path $PSHOME -ChildPath 'powershell.exe'),

        [Parameter(ParameterSetName='History')]
        [Switch]
        $Last,

        [Switch]
        $NoExit,

        [Parameter(ParameterSetName='Script')]
        [ValidateScript({
            If(Test-Path -Path $_ -PathType Leaf)
            {
                $true
            }
            Else
            {
                Throw "$_ is not a valid Path"
            }})]
        [System.String]
        $Script
    )

    #Base parameters for the start-process cmdlet
    $startProcessSplat = @{
        FilePath = $Application
        Verb = 'RunAs'
        ErrorAction = 'Stop'
    }
    
    $applicationIsPowershell = $Application -match 'powershell.exe$'
    

    If($Last)
    {
        $lastCommand = Get-History | 
            Select-Object -ExpandProperty CommandLine -Last 1
        $processArguments = "-command $lastCommand"
    }
    
    If($Script)
    {
        $Script = Resolve-Path -Path $Script
        $processArguments = ('-file "{0}"' -f $Script)
    }

    If($Scriptblock -and $applicationIsPowershell )
    {
        $processArguments = "-command $Scriptblock"
    } 
    ElseIf($Scriptblock)
    {
        $processArguments = "$Scriptblock"
    }

    If($NoExit -and $applicationIsPowershell)
    {
        $processArguments = ' -NoExit {0}' -f $processArguments
    }

    If($processArguments)
    {
        Write-Verbose -Message "Starting: $($Application) as administrator with Arguments: $($processArguments)"
        $startProcessSplat['ArgumentList'] = $processArguments
    }
    Else
    {
        Write-Verbose -Message "Starting: $($Application) as administrator"
    }
    
    Try
    {
        Start-Process @startProcessSplat
    }
    Catch
    {
        Write-Warning -Message ("Error starting process. Error Message: {0}" -f $_.Exception.Message)
    }
}

Set-Alias -Name Sudo -Value Start-ElevatedProcess