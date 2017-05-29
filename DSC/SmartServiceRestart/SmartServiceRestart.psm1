[DscResource()]
class SmartServiceRestart
{

    [DscProperty(Key)]
    [string]
    $ServiceName

    [DscProperty(Mandatory)]
    [string[]]
    $Path

    [DscProperty()]
    [String]
    $Filter

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]]
    $ProcessStartTime

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]]
    $LastWriteTime

    [DateTime]GetLastWriteTime()
    {
        $getSplat = @{
            Path    = $this.Path
            Recurse = $true
        }

        Write-Verbose -Message "Checking Path: $($this.Path -join ", ")"
        if ($this.Filter)
        {
            Write-Verbose -Message "Using Filter: $($this.Filter)"
            $getSplat["Filter"] = $this.Filter
        }

        $lastWrite = Get-ChildItem @getSplat |
            Sort-Object -Property LastWriteTime |
            Select-Object -ExpandProperty LastWriteTime -First 1

        if (-not($lastWrite))
        {
            Write-Verbose -Message "No last write time found. Setting to min date"
            $lastWrite = [datetime]::MinValue
        }

        Write-Verbose -Message "Last write time: $lastWrite"
        return $lastWrite
    }

    [DateTime]GetProcessStartTime()
    {
        $service = Get-CimInstance -ClassName Win32_Service -Filter "Name='$($this.ServiceName)'" -ErrorAction Stop
        if (-not($service))
        {
            Throw "Could not find a service with name: $($this.ServiceName)"
        }

        Write-Verbose -Message "Checking for process id: $($service.ProcessId)"
        $processInfo = (Get-CimInstance win32_process -Filter "processid='$($service.ProcessId)'")

        if ($processInfo.ProcessId -eq 0)
        {
            Write-Verbose -Message "Could not find a running process, setting start time to min date value"
            $processStart = [datetime]::MinValue
        }
        else
        {
            $processStart = $processInfo.CreationDate
            Write-Verbose -Message "Process started at: $($processStart)"
        }
        return $processStart
    }

    [SmartServiceRestart]Get()
    {
        $this.ProcessStartTime = $this.GetProcessStartTime()
        $this.LastWriteTime = $this.GetLastWriteTime()
        return $this
    }

    [bool]Test()
    {
        $this.ProcessStartTime = $this.GetProcessStartTime()
        $this.LastWriteTime = $this.GetLastWriteTime()

        Write-Verbose -Message "PID: [$($this.ProcessStartTime)]. File Last Write Time: [$($this.LastWriteTime)]"
        if ($this.ProcessStartTime -gt $this.LastWriteTime)
        {
            return $true
        }
        else
        {
            return $false
        }
    }

    [Void]Set()
    {
        Restart-Service -Name $this.ServiceName -Force
    }
}