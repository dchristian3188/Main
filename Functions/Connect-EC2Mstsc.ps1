Function Connect-EC2Mstsc
{
    [CmdletBinding(DefaultParameterSetName = 'EC2Instance')]
    Param(
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'InstanceID')]
        [String]
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
        if(![string]::IsNullOrEmpty($InstanceId))
        {
            $InputObject = Get-EC2Instance -InstanceId $InstanceId
        }

        foreach($instance in $InputObject.Instances)
        {
            if ($null -eq $instance)
            {
                Write-Error -Message  "Invalid EC2 Instance"
            }
    
            $publicIP = $instance.PublicIpAddress
            if([String]::IsNullOrEmpty($publicIP))
            {
                Write-Error -Message "No public IP address for instance [$($instance.InstanceId)]"
            }
            
            $cred = $instance | 
                Get-EC2Credential -PemFile $PemFile
            
            Connect-Mstsc -ComputerName $publicIP -Credential $cred
        }
    }
}

Get-EC2Instance | ? { $PSItem.instances.state.name -eq 'running' } | 
    Connect-EC2Mstsc -PemFile C:\aws\OverPoweredShell.pem