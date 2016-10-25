#New-ScheduledTask
#New-ScheduledTaskAction
#New-ScheduledTaskPrincipal
#New-ScheduledTaskSettingsSet
#New-ScheduledTaskTrigger
# Define a class
class myClass
{
    [String]$Name
    [Int]$boogers
}

[DscResource()]
class ScheduledTask
{
    [DscProperty(Key)]
    [string]$P1
 
    [DscProperty()]
    [myClass]$HI

    # Sets the desired state of the resource.
    [void] Set()
    {        
    }        
    
    # Tests if the resource is in the desired state.
    [bool] Test()
    {        
        return $true
    }    
    # Gets the resource's current state.
    [ScheduledTask] Get()
    {        
        return $this 
    }    

}
