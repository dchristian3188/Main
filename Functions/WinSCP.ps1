Add-Type -Path "PATH_TO_DLL"

Function Get-WinSCP
{
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [String]
        $URL ='https://cdn.winscp.net/files/WinSCP-5.9.2-Automation.zip?secure=N0G_4Zpd4iym8aZOlf_FMg==,1477365938',

        [Parameter()]
        [String]
        $Destination = (Get-Location).Path,

        [Parameter()]
        [Switch]
        $Force
    )
    Process
    {
        If($Destination = (Get-Location).Path)
        {
            $Destination = Join-Path -Path $Destination -ChildPath "WinSCP"
        }
        Write-Verbose -Message "Destination set to $Destination"
        
        $zipPath = (New-TemporaryFile).FullName.Replace('.tmp','.zip')
        Write-Verbose -Message "Saving zip to $zipPath"
        Invoke-WebRequest -Uri $URL -UseBasicParsing -OutFile $zipPath

        $exPandSplat = @{
            Path = $zipPath
            DestinationPath = $Destination
        }

        If($Force)
        {
            $exPandSplat['Force'] = $true
        }

        Expand-Archive @exPandSplat
    }
    End
    {
    }
}
Function New-WinSCPSessionOptions
{
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [ValidateSet('Active','Passive')]
        [String]
        $FTPMode,

        [Parameter()]
        [ValidateSet('None','Implicit','Explicit')]
        [String]
        $FtpSecure,

        [Parameter()]
        [Bool]
        $GiveUpSecurityAndAcceptAnySshHostKey,

        [Parameter()]
        [Bool]
        $GiveUpSecurityAndAcceptAnyTlsHostCertificate,

        [Parameter()]
        [String]
        $Hostname,
        
        [Parameter()]
        [String]
        $Password,

        [Parameter()]
        [Int]
        $ProtNumber,

        [Parameter()]
        [String]
        $PrivateKeyPassphrase,

        [Parameter()]
        [ValidateSet('SFTP','SCP','FTP','WebDav')]
        [String]
        $Protocol,

        [Parameter()]
        [SecureString]
        $SecurePassword,

        [Parameter()]
        [String]
        $SshHostKeyFingerprint,

        [Parameter()]
        [String]
        $SshPrivateKeyPassphrase,

        [Parameter()]
        [String]
        $SshPrivateKeyPath,

        [Parameter()]
        [TimeSpan]
        $TimeOut,

        [Parameter()]
        [Int]
        $TimeoutInMilliseconds,

        [Parameter()]
        [String]
        $TlsClientCertificatePath,

        [Parameter()]
        [String]
        $TlsHostCertificateFingerprint,

        [Parameter()]
        [String]
        $UserName,

        [Parameter()]
        [String]
        $WebdavRoot,

        [Parameter()]
        [String]
        $WebdavSecure

    )
    
    $session = New-Object -TypeName WinSCP.SessionOptions
    $sessionProps = $session | 
        Get-Member | 
        Where-Object -FilterScript {$PSItem.MemberType -eq 'Property'}

    $parameters = $MyInvocation.MyCommand.Parameters.Keys | 
        Where-Object {$sessionProps.Name -contains $PSItem }
    
    $parameters.ForEach{
        $propertyName = $PSItem
        $propertyValue = Get-Variable -Name $propertyName -ValueOnly 
        If($propertyValue)
        {
            $session.$propertyName = $propertyValue
        }
    }

    Write-Output $session

    
}
New-WinSCPSessionOptions -FTPMode Passive -GiveUpSecurityAndAcceptAnySshHostKey $false -TimeoutInMilliseconds 600 -PrivateKeyPassphrase "boogers"