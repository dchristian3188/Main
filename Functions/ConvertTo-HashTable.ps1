Function ConvertTo-HashTable
{
    <#
    .Synopsis
       Converts incoming object to a hashtable.
    .DESCRIPTION
       Converts incoming object to a hashtable.
    .PARAMETER InputObject
        Object to be converted
    .PARAMETER IncludeNullValues
        Optional parameter. If present adds properties 
        with null values to the hashtable
    .EXAMPLE
       Get-Service -Name Spooler | ConvertTo-HashTable
        Name                           Value                                                                
        ----                           -----                                                                
        CanStop                        True                                                                 
        ServiceName                    Spooler                                                              
        DisplayName                    Print Spooler                                                        
        ServiceType                    Win32OwnProcess, InteractiveProcess                                  
        RequiredServices               {RPCSS, http}                                                        
        CanPauseAndContinue            False                                                                
        Name                           Spooler                                                              
        MachineName                    .                                                                    
        ServicesDependedOn             {RPCSS, http}                                                        
        CanShutdown                    False                                                                
        Status                         Running                                                              
        DependentServices              {Fax}                                                                
        StartType                      Automatic                                                            

    .NOTES
        Created by David Christian
    .Link
        https://github.com/dchristian3188
    #>

    [CmdletBinding()]
    [OutputType([HashTable])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true, 
                   ValueFromPipelineByPropertyName=$true, 
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch]
        $IncludeNullValues=$false
    )
    Begin
    {
    }
    Process
    {
        ForEach($object in $InputObject)
        {
            $propertyHash = @{}
            $object.PSobject.Properties.Name.ForEach{
                $propertyName = $PSItem
                $currentValue = $object.$propertyName

                If($IncludeNullValues)
                {
                    $propertyHash[$propertyName] = $object.$propertyName
                }
                ElseIf(![System.String]::IsNullOrEmpty($currentValue))
                {
                    $propertyHash[$propertyName] = $object.$propertyName
                }
            }
            Write-Output -InputObject $propertyHash
        }
    }
    End
    {
    }
}