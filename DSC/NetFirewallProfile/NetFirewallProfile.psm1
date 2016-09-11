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
        Write-Verbose -Message "Testing Profile: $($this.Name) with Filter: $($whereString)"
        $whereFilter = [scriptblock]::Create($whereString)
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
        
        $this.Enabled = [GpoBoolean]::$($currentState.Enabled)     
        $this.DefaultInboundAction = [Action]::$($currentState.DefaultInboundAction)
        $this.DefaultOutboundAction = [Action]::$($currentState.DefaultOutboundAction)
        $this.AllowInboundRules = [Action]::$($currentState.AllowInboundRules)
        $this.AllowLocalFirewallRules = [Action]::$($currentState.AllowLocalFirewallRules)
        $this.AllowLocalIPsecRules = [Action]::$($currentState.AllowLocalIPsecRules)
        $this.AllowUserApps = [Action]::$($currentState.AllowUserApps)
        $this.AllowUserPorts = [Action]::$($currentState.AllowUserPorts)
        $this.AllowUnicastResponseToMulticast = [Action]::$($currentState.AllowUnicastResponseToMulticast)
        $this.NotifyOnListen = [GpoBoolean]::$($currentState.NotifyOnListen)
        $this.EnableStealthModeForIPsec = [GpoBoolean]::$($currentState.EnableStealthModeForIPsec)
        $this.LogFileName = $currentState.LogFileName
        $this.LogMaxSizeKilobytes = $currentState.LogMaxSizeKilobytes
        $this.LogAllowed = [GpoBoolean]::$($currentState.LogAllowed)
        $this.LogBlocked = [GpoBoolean]::$($currentState.LogBlocked)
        $this.DisabledInterfaceAliases = $currentState.DisabledInterfaceAliases
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