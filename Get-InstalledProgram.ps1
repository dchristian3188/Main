Function Get-InstalledProgram
{
<#
    .SYNOPSIS
        Gets the installed programs from add / remove programs.

    .DESCRIPTION
        This function queries the registry for installed programs. 

    .PARAMETER  DisplayName
        Optional filter. Name of the program. Supports wild cards.

    .PARAMETER  Publisher
        Optional filter. Name of the application vendor. Supports wild cards.

    .EXAMPLE
        Get-InstalledPrograms 

    .EXAMPLE
        Get-InstalledPrograms -Publisher VMware* 
    
    .EXAMPLE
        Get-InstalledPrograms | Out-GridView

    .INPUTS
        System.String,System.String

    .OUTPUTS
        PSCustomObject

    .NOTES
        Created by:   David Christian

    .LINK
        https://github.com/dchristian3188
#>
    
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        [Alias('Name')]    
        [System.String] 
        $DisplayName,
      
        [Parameter(ValueFromPipelineByPropertyName=$true,
                    Position=1)]
        [Alias('Vendor')]
        [System.String]
        $Publisher
    )
    
    #region Filter Prep
    $whereFilter = '![System.String]::IsNullOrEmpty($_.DisplayName)'
    Write-Verbose -Message "Base Where filter: $whereFilter"
    
    If($DisplayName)
    {
        $whereFilter = '{0} -and ($_.DisplayName -like "{1}")' -f $whereFilter,$DisplayName
        Write-Verbose -Message "Adding display filter: $whereFilter"
    }
    
    If($Publisher)
    {
        $whereFilter = '{0} -and ($_.Publisher -like "{1}")' -f $whereFilter,$Publisher
        Write-Verbose -Message "Adding publisher filter: $whereFilter"
    }
    
    $whereBlock = [scriptblock]::Create($whereFilter)
    #endregion Filter Prep
    
    #region Uninstall Registy Keys

    $UNINSTALL_ROOT = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $UNINSTALL_WOW = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $UNINSTALL_USER = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $UNINSTALL_WOWUSER = "HKCU:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"

    #endRegion Uninstall Registy Keys
        
    $regPath = @{Name='RegistryKey';Expression={$_.PSPath.Split('::')[-1]}}

    [System.String[]]$RegKeys = @(
        $UNINSTALL_ROOT, 
        $UNINSTALL_USER, 
        $UNINSTALL_WOW, 
        $UNINSTALL_WOWUSER
    )

    ForEach ($key in $RegKeys) {
        If(Test-Path -Path $key){
            Write-Verbose -Message "Reading $key"
            
            $regKeyColumn = @{Name='RegistyKey';Expression={$key}}
            Try
            {
                Get-ItemProperty -Path $key  -Name *  -ErrorAction 'Stop' | 
                    Where-Object $whereBlock | 
                    Select-Object -Property DisplayName,
                                            DisplayVersion,
                                            Publisher,
                                            UninstallString,
                                            $regPath
            }
            Catch
            {
                Write-Warning -Message $_.Exception.Message
            }#end Catch
        }
    }#end foreach key
}#end Get-InstalledProgram
