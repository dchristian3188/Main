Function Get-Netstat
{
    <#
	.SYNOPSIS
		Displays active TCP connections.

	.DESCRIPTION
		Displays active TCP connections similiar to the netstat command.
        Can be used as a replacement for Get-NetTCPConnection on OS newer than
        Server 2012 / Windows 8

	.PARAMETER  ComputerName
		The computername to query

	.PARAMETER  Resolve
		If switch is present, will attempt to resolve ip address to hostname
    
    .PARAMETER  ShowTCPListeners
		If switch is present, will display currently listening TCP connections
    
    .PARAMETER  ShowUDPListeners
		If switch is present, will display currently listening UDP connections
	
    .EXAMPLE
		PS C:\> Get-Netstat 
		Will display current TCP connections for local machine

	.EXAMPLE
		PS C:\>Get-Netstat -Computername Server01,Server02
		Displays current netstat information for server01 and server02
    
    .EXAMPLE
        PS C:\> Get-Netstat -ShowTCPListeners -ShowUDPlisteners | ogv
        Will retrieve all open connections on the localmachine. The results are
        sent to Out-Gridview.
    
	.INPUTS
		System.String,Switch

	.OUTPUTS
		PSCustomObject

	.NOTES
        Created by:   David Christian

	.LINK
		https://github.com/dchristian3188/Scripts

#>
	[CmdletBinding()]
	Param
    (
		[Parameter(ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        [Alias('CN')]
        [System.String[]]
		$ComputerName = $env:COMPUTERNAME,
    
        [Parameter()]
        [Switch]
        $Resolve = $false,
    
        [Parameter()]
        [Switch]
        $ShowTCPListeners = $false,
    
        [Parameter()]
        [Switch]
        $ShowUDPListeners = $false
	)
	Begin 
    {
		$ipSciptBlock={
            Param 
            (
                $ResolveHosts,
                $ShowTCPListener,
                $ShowUDPListener
            )
            $ipGlobalProps = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
            
            #region TCP Connections
            $ipConnections = $ipGlobalProps.GetActiveTcpConnections()
            ForEach($connection in $ipConnections)
            {
                If($ResolveHosts)
                {
                    $remoteAddress = [System.Net.Dns]::Resolve($connection.RemoteEndPoint.Address) | 
                                        Select-Object -ExpandProperty Hostname
				}
                Else
                {
                    $remoteAddress = $connection.RemoteEndPoint.Address
				}
                
                $connectionProperties = @{
                        ComputerName = $env:COMPUTERNAME
                        Protocol = 'TCP'
                        ConnectionState = $connection.State
                        LocalAddress = $connection.LocalEndPoint.Address
                        LocalPort = $connection.LocalEndPoint.Port
                        RemoteAddress = $remoteAddress
                        RemotePort = $connection.RemoteEndPoint.Port
                        IPFamily = If($connection.LocalEndPoint.AddressFamily -eq 'InterNetwork'){"IPv4"}Else{"IPv6"}
			    }
                New-Object -TypeName PSObject -Property $connectionProperties
			}
            #endregion TCP Connections
            
            #region TCP Listeners
            If($ShowTCPListener)
            {
                $ipConnections = $ipGlobalProps.GetActiveTcpListeners()
                
                ForEach ($connection in $ipConnections)
                {
                	$connectionProperties = @{
                        ComputerName = $env:COMPUTERNAME
                        Protocol = 'TCP'
                        ConnectionState = 'Listening'
                        LocalAddress = $connection.Address
                        LocalPort = $connection.Port
                        RemoteAddress = '*'
                        RemotePort = '*'
                        IPFamily = if($connection.AddressFamily -eq 'InterNetwork'){"IPv4"}else{"IPv6"}
					}
                    New-Object -TypeName PSObject -Property $connectionProperties
			    }
            }
            #endregion TCP Listeners
            
            #region UDP Listeners
            If($ShowUDPListener)
            {
                $ipConnections = $ipGlobalProps.GetActiveUdpListeners()
                
                ForEach($connection in $ipConnections) 
                {
                	$connectionProperties = @{
                        ComputerName = $env:COMPUTERNAME
                        Protocol = 'UDP'
                        ConnectionState = 'Listening'
                        LocalAddress = $connection.Address
                        LocalPort = $connection.Port
                        RemoteAddress = '*'
                        RemotePort = '*'
                        IPFamily = if($connection.AddressFamily -eq 'InterNetwork'){"IPv4"}else{"IPv6"}
					}
                    New-Object -TypeName PSObject -Property $connectionProperties
			    }
            }
            #endregion UDP Listeners
		}
	}
	Process
    {
        ForEach($computer in $ComputerName) 
        {
        	If($computer -match "^$env:COMPUTERNAME$|localhost")
            {
                $ipSciptBlock.Invoke($Resolve,$ShowTCPListeners,$ShowUDPListeners) |  
                    Select-Object -Property ComputerName,LocalAddress,LocalPort,RemoteAddress,RemotePort,Protocol,ConnectionState,IPFamily
			}
            Else
            {
                Try
                {
                    Test-WSMan -ComputerName $computer -ErrorAction 'Stop' > $null
                    Invoke-Command -ComputerName $computer -ScriptBlock $ipSciptBlock -ArgumentList $Resolve,$ShowTCPListeners,$ShowUDPListeners |
                        Select-Object -Property ComputerName,LocalAddress,LocalPort,RemoteAddress,RemotePort,Protocol,ConnectionState,IPFamily
				}
                Catch
                {
                    Write-Warning -Message ("Unable to connect to '{0}'. Error Message: {1}" -f $computer,$_.Exception.Message)
				}
			}
        }
	}
	End
    {
	}
}