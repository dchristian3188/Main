Function ConvertTo-BinaryAddress
{
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ipaddress]
        $Address
    )
    process
    {
        $octets = $address.GetAddressBytes()
        $result = foreach ($octet in $octets)
        {
            [convert]::ToString($octet, 2).PadLeft(8,'0')
        }
        Write-Output -InputObject $($result -join '.')
    }
}
