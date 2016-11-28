Function New-WinSCPSessionOptions
{
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
        $PortNumber,

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
        Get-Member -MemberType Properties

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

    Write-Output -InputObject $session
}
