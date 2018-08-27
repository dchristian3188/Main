Function Get-EC2Credential
{
    [CmdletBinding(DefaultParameterSetName = 'EC2Instance')]
    Param(
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'InstanceID')]
        [String[]]
        $InstanceId,

        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'EC2Instance')]
        [PSCustomObject]
        $InputObject,

        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [ValidateScript(
            {
                if (-not(Test-Path -Path $PSItem))
                {
                    throw "Unable to find PemFile at path [$psitem]"
                }
                else
                {
                    $true
                }
            }
        )]
        [string]
        $PemFile
    )

    Process
    {
        if ($null -ne $InputObject.Instances.InstanceID)
        {
            $InstanceId = $InputObject.Instances.InstanceID
        }

        if ($null -ne $InputObject.InstanceID)
        {
            $InstanceId = $InputObject.InstanceID
        }
        
        foreach($insID in $InstanceId)
        {
            $securePassword = Get-EC2PasswordData -InstanceId $insID -PemFile $PemFile |
                ConvertTo-SecureString -AsPlainText -Force
                [PSCredential]::new('administrator', $securePassword)
        }
    }
}

#Get-EC2Instance | ? { $PSItem.instances.state.name -eq 'running' }| select -skip 1 | Get-EC2Credential -Verbose -PemFile C:\aws\OverPoweredShell.pem

