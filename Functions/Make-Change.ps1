Function Make-Change
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        [Int]
        $Amount,
   
        [Parameter(Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=1)]
        [Int[]]
        $Coins
    )

    $numberOfCoins = $Coins.Count
    $table = New-Object -TypeName Int32[] -ArgumentList $($Amount+1)
    $results = New-Object -TypeName HashTable[] -ArgumentList $($Amount+1)
    
    #if 0 Amount is passed
    $table[0] = 0
    $results[0] = @{}

    #set all results as invalid. 
    #Can't check if soultion is more efficient if value is 0
    #see test/var $newValueFewerCoins
    For($currentAmount = 1; $currentAmount -le $Amount; $currentAmount++)
    {
        $table[$currentAmount] = [int32]::MaxValue
    }

    For($currentAmount = 1; $currentAmount -le $Amount; $currentAmount++)
    {
        #loop thru each coin smaller than current amount
        For($coinIndex = 0; $coinIndex -lt $numberOfCoins; $coinIndex++)
        {
            $currentCoin = $Coins[$coinIndex]
            $keyName = "C-{0}" -f $currentCoin

            If($currentCoin -le $currentAmount)
            {
                #store results of previous subproblem
                $previousSubProblem = $currentAmount-$currentCoin
                $subResult = $table[$previousSubProblem]
                $subHash = $results[$previousSubProblem]

                #if new value is samller. Take that result and add one coin
                $newValueFewerCoins =  ($subResult + 1) -lt $table[$currentAmount]
                If($newValueFewerCoins)
                {
                    $table[$currentAmount] = $subResult + 1
                    $results[$currentAmount] = $subHash.Clone()
                    $results[$currentAmount][$keyName] = $subHash[$keyName] + 1
                }
            }
        }
    }

    [PSCustomObject]$results[$Amount] | 
        Select-Object @{N='Amount';E={$Amount}},*
}

Make-Change -Amount 48 -Coins 25,24,5,1
Make-Change -Amount 50 -Coins 25,10,5,1
Make-Change -Amount 61 -Coins 25,10,5,1