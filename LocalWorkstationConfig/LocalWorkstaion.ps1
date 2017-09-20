configuration LocalWorkstation {
    Import-DscResource -ModuleName cChoco
    Import-DscResource -ModuleName PowerShellModule
    node ("localhost")
    {

        file Github 
        {
            DestinationPath = 'C:\github'
            Type = "Directory"
        }   
        foreach($package in $ConfigurationData.NonNodeData.Packages)
        {
            cChocoPackageInstaller $package {
                Name = $package
                AutoUpgrade = $true
            }
        }

        foreach($module in $ConfigurationData.NonNodeData.Modules)
        {
            PSModuleResource $module
            {
                Module_Name =  $module
            }
        } 

        Script ProfileContainsBase {
            GetScript = {
                Get-Content -Path $using:profile
            }

            TestScript = {
                $BASE_PROFILE_PATH = 'C:\github\Main\LocalWorkstationConfig\Microsoft.PowerShell_profile.ps1'
                if(Test-Path -Path $using:profile)
                {
                    $contents = Get-Content -Path $using:profile
                    $results = $contents -match [regex]::Escape($BASE_PROFILE_PATH)
                    if($results)
                    {
                        return $true
                    }
                    else
                    {
                        return $false   
                    }
                }
                else 
                {
                    return $false
                }
            }

            SetScript = {
                $BASE_PROFILE_PATH = 'C:\github\Main\LocalWorkstationConfig\Microsoft.PowerShell_profile.ps1'
                Write-Output -InputObject "`n. $($BASE_PROFILE_PATH)`n" >> $using:profile
            }
        }
    }
}

$MyData = @{
    AllNodes =
    @(

    );
    NonNodeData = @{
        Packages = (Get-Content -Path "$PSScriptRoot\Packages.txt")
        Modules = (Get-Content -Path "$PSScriptRoot\Modules.txt")
    } 
}
New-Item -ItemType Directory -Path C:\PS -ErrorAction 0
Set-Location -Path C:\PS


LocalWorkstation -ConfigurationData $MyData
Start-DscConfiguration -Verbose -Force -Wait -Path .\LocalWorkstation\