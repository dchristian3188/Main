Install-Module -Name PowerShellModule, cChoco
Enable-PSRemoting -Force -Verbose
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))