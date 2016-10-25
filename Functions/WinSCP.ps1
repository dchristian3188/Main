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
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Active','Passive')]
        [String]
        $FTPMode,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('None','Implicit','Explicit')]
        [String]
        $FtpSecure,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Bool]
        $GiveUpSecurityAndAcceptAnySshHostKey,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Bool]
        $GiveUpSecurityAndAcceptAnyTlsHostCertificate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $Hostname,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $Password,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Int]
        $ProtNumber,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $PrivateKeyPassphrase,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('SFTP','SCP','FTP','WebDav')]
        [String]
        $Protocol,

        [Parameter(ValueFromPipelineByPropertyName)]
        [SecureString]
        $SecurePassword,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $SshHostKeyFingerprint,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $SshPrivateKeyPassphrase,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $SshPrivateKeyPath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [TimeSpan]
        $TimeOut,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Int]
        $TimeoutInMilliseconds,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $TlsClientCertificatePath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $TlsHostCertificateFingerprint,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $UserName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $WebdavRoot,

        [Parameter(ValueFromPipelineByPropertyName)]
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