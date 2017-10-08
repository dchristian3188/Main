Function Publish-ESDocument
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]
        $IndexName,

        [Parameter(Mandatory)]
        [String]
        $DocumentType,

        [Parameter(Mandatory)]
        [PSCustomObject]
        $InputObject,

        [Parameter()]
        [Alias('ServerName')]
        [Uri]
        $ElasticSearchServer,
        
        [Parameter()]
        [PSCredential]
        $Credential
    )

    Begin
    {
        
        $newDocURI = "$($ElasticSearchServer)$($IndexName)/$($DocumentType)".ToLower()
        $newDocSplat = @{
            URI             = $newDocURI
            Method          = 'Post'
            UseBasicParsing = $true
            Body            = $body
            ContentType     = 'application/json'
        }
        if ($Credential)
        {
            $newDocSplat['Credential'] = $Credential
        }
    
    }

    Process
    {
        foreach ($object in $InputObject)
        {
            $body = $object | 
                ConvertTo-Json 
            $newDocSplat['Body'] = $body
            Invoke-RestMethod @newDocSplat
        }   
    }
}

$es = 'http://server1:9200'
$Object = Get-Service -Name S*, A*  | 
    Select-Object Name, DisplayName, Status
Publish-ESDocument -IndexName Service -DocumentType ServiceEntry -InputObject $Object -Verbose -ElasticSearchServer $es