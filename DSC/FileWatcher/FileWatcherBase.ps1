[DscResource()]
class SmartSeviceRestart
{

    [DscProperty(Key)]
    [string]
    $ServiceName

    [DscProperty(Mandatory)]
    [String[]]
    $Path

    [DscProperty(Mandatory)]
    [String]
    $Filter
    
    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] 
    $ProcessStartTime

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] 
    $LastWriteTime

    [Bool] Test()
    {        
        If (-not($this.ProcessStartTime))
        {
            $this.ProcessStartTime = $this.GetProcessStartTime()
        }

        If (-not($this.LastWriteTime))
        {
            $this.LastWriteTime = $this.GetLastWriteTime()
        }

        If ($this.ProcessStartTime -ge $this.LastWriteTime)
        {
            Return $true
        }
        Else
        {
            Return $false
        }
    } 
       
    [SmartSeviceRestart]Get()
    {        
        $this.ProcessStartTime = $this.GetProcessStartTime()
        $this.LastWriteTime = $this.GetLastWriteTime()
        Return $this
    } 
    
    [Void]Set()
    {
        Restart-Service -Name $this.ServiceName -Force
    }
    
    [DateTime]GetProcessStartTime()
    {
        $service = Get-CimInstance -ClassName Win32_Service -Filter "Name='$($this.ServiceName)'" -ErrorAction Stop
        If (-not($service))
        {
            Throw "Could not find a service with name: $($this.ServiceName)"
        }

        Write-Verbose -Message "Checking for process id: $($service.ProcessId)"
        $processInfo = (Get-CimInstance win32_process -Filter "processid='$($service.ProcessId)'")
        
        If ($processInfo.ProcessId -eq 0)
        {
            Write-Verbose -Message "Could not find a running process, setting start time to min date value"
            $processStart = [datetime]::MinValue
        }
        Else
        {
            $processStart = $processInfo.CreationDate
            Write-Verbose -Message "Process started at: $($processStart)"
        }
        Return $processStart
    }

    [DateTime]GetLastWriteTime()
    {
        $getSplat = @{
            Path = $this.Path
            Recurse = $true
        }

        Write-Verbose -Message "Checking Path: $($this.Path -join ", ")"
        If ($this.Filter)
        {
            Write-Verbose -Message "Using Filter: $($this.Filter)"
            $getSplat["Filter"] = $this.Filter
        }

        $lastWrite = Get-ChildItem @getSplat |
            Sort-Object -Property LastWriteTime |
            Select-Object -ExpandProperty LastWriteTime -First 1
        
        if (-not($lastWrite))
        {
            Write-Verbose -Message "No lastwrite time found. Setting to min date"
            $lastWrite = [datetime]::MinValue
        }

        Write-Verbose -Message "Last write time: $lastWrite"
        return $lastWrite
    }
}