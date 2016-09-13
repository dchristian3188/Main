Enum Action
{
    NotConfigured
    Allow
    Block
}

Enum GpoBoolean
{
    NotConfigured
    True
    False
}

[DscResource()]
class NetFirewallProfile
{

    [DscProperty(Key)]
    [String]
    $Name

    [DscProperty(Mandatory)]
    [GpoBoolean]
    $Enabled

    [DscProperty()]
    [Action]
    $DefaultInboundAction

    [DscProperty()]
    [Action]
    $DefaultOutboundAction
    
    [DscProperty()]
    [GpoBoolean]
    $AllowInboundRules
    
    [DscProperty()]
    [GpoBoolean]
    $AllowLocalFirewallRules
    
    [DscProperty()]
    [GpoBoolean]
    $AllowLocalIPsecRules
    
    [DscProperty()]
    [GpoBoolean]
    $AllowUserApps

    [DscProperty()]
    [GpoBoolean]
    $AllowUserPorts
    
    [DscProperty()]
    [GpoBoolean]
    $AllowUnicastResponseToMulticast
    
    [DscProperty()]
    [GpoBoolean]
    $NotifyOnListen

    [DscProperty()]
    [GpoBoolean]
    $EnableStealthModeForIPsec

    [DscProperty()]
    [String]
    $LogFileName

    [DscProperty()]
    [UInt64]
    $LogMaxSizeKilobytes

    [DscProperty()]
    [GpoBoolean]
    $LogAllowed
    
    [DscProperty()]
    [GpoBoolean]
    $LogBlocked
    
    [DscProperty()]
    [String[]]
    $DisabledInterfaceAliases
    
    [void] Set()
    {
        $profileSplat = $this.ConvertoHash()
        Set-NetFirewallProfile @profileSplat
    }        
    
    [bool] Test()
    {        
        $propertyHash = $this.ConvertoHash()
        
        $whereString = $this.ConvertToWhere($propertyHash)
        $whereFilter = [scriptblock]::Create($whereString)
        Write-Verbose -Message "Testing Profile: $($this.Name) with Filter: $($whereString)"
        
        $foundProfile = Get-NetFirewallProfile | 
            Where-Object $whereFilter
        If($foundProfile)
        {
            Return $true
        }
        Else
        {
            Return $false
        }
    }    
    
    [NetFirewallProfile] Get()
    {   
        $currentState = Get-NetFirewallProfile -Name $this.Name
        $classDefinition = $this | Get-Member

        ForEach($property in $classDefinition.Where{$PSItem.Membertype -eq "Property"})
        {
            $propertyName = $property.Name
            Switch($property.Definition)
            {
                {$PSItem -match 'Action'} {$this.$propertyName = [Action]::$($currentState.$propertyName).ToString()}
                {$PSItem -match 'GpoBoolean'} {$this.$propertyName = [GpoBoolean]::$($currentState.$propertyName).ToString()}
                Default {$this.$propertyName = $currentState.$propertyName}
            }
        }

        return $this
    }

    [HashTable]ConvertoHash()
    {
        $propertyHash = @{}
        $stringProperties = $this.PSObject.Properties.Where{$PSItem.TypeNameOfValue -notmatch 'int'}
        [PSCustomObject[]]$stringProperties.Name.ForEach{
            $property = $PSItem

            $stringNotEmpty = ![System.String]::IsNullOrEmpty($this.$property)
            $validValuePassed = $this.$property -ne 'NotConfigured'
            If($stringNotEmpty -and $validValuePassed)
            {
                $propertyHash[$property] = $this.$property.ToString()
            }
        }

        $intProperties = $this.PSObject.Properties.Where{$PSItem.TypeNameOfValue -match 'int'}
        [PSCustomObject[]]$intProperties.Name.ForEach{
            $property = $PSItem
            If($this.$property)
            {
                $propertyHash[$property] = $this.$property
            }
        }
        return $propertyHash
    }

    [String]ConvertToWhere([HashTable]$propertyHash)
    {
        $raw = ForEach($property in $propertyHash.Keys)
        {
            Write-Output -InputObject ('($PSItem.{0} -eq "{1}")' -f $property,$propertyHash[$property])
        }

        $whereFilter = $raw -join " -and "
        Return $whereFilter
    }
}