Function Get-WinSCPFile
{
    Param
    (
        [Parameter(Mandatory,
                    ValueFromPipelineByPropertyName)]
        [String[]]
        $Path,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $Destination,

        [Parameter(Mandatory,
                    ValueFromPipelineByPropertyName)]
        [WinSCP.SessionOptions]
        $SessionOptions,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Switch]
        $RemoveRemoteFile

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $LogPath
    )
    Begin
    {
        $session = New-Object -TypeName WinSCP.Session
        If (-Not([String]::IsNullOrEmpty($LogPath)))
        {
          $session.SessionLogPath = $LogPath
        }
        Try
        {
            $session.Open($SessionOptions)
        }
        Catch
        {
            Write-Error "Error Opening Session: $($PSItem.Exception.Message)"
            Throw $PSItem
        }
        $Destination = [System.IO.Path]::GetFullPath($Destination)
    }
    Process
    {
        ForEach($file in $Path)
        {
            IF($session.FileExists($file))
            {
                If([String]::IsNullOrEmpty($Destination))
                {
                    $localDest = Split-Path -Path $file -Leaf
                }
                ElseIf(Test-Path -Path $Destination)
                {
                    $pathIsFolder = (Get-Item -Path $Destination).PSIsContainer
                    If($pathIsFolder)
                    {
                        $localDest = Join-Path -Path $Destination -ChildPath (Split-Path -Path $file -Leaf)
                    }
                    Else
                    {
                        $localDest = $Destination
                    }
                }
                Else
                {
                    $localDest = $Destination
                }

                $transfer =  $session.GetFiles($file,$localDest,$RemoveRemoteFile)
                $transfer
                If(-not($transfer.IsSuccess))
                {
                    Write-Error -Message $transfer.Failures
                }
            }
            Else
            {
                Write-Error -Message "Unable to find remote file at $file"
            }
        }
    }
    End
    {
        $session.close()
    }
}
