Configuration FirewallExample
{
    Import-DscResource -Name NetFirewallProfile
    node localhost
    {
        NetFirewallProfile PrivateProfile
        {
            Name = "Private"
            Enabled = "False"
        }

        NetFirewallProfile PublicProfile
        {
            Name = "Public"
            Enabled = "True"
            DefaultInboundAction = "Block"
            DefaultOutboundAction = "Allow"
            AllowUserApps = "False"
            AllowInboundRules = "True"
            AllowUserPorts = "False"
            EnableStealthModeForIPsec = "True"
        }
    }
}