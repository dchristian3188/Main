configuration RestartExample 
{
    Import-DscResource -ModuleName SmartServiceRestart
    node ('localhost')
    {
        SmartServiceRestart PrintSpooler
        {
            ServiceName = 'Spooler'
            Path        = 'C:\temp\controller.txt'
        }
    }
}