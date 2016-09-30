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
    $table = New-Object -TypeName "Int32[]" -ArgumentList $($Amount+1)
    $results = New-Object -TypeName "HashTable[]" -ArgumentList $($Amount+1)
    
    #if 0 Amount is passed
    $table[0] = 0
    $results[0] = @{}

    #set all results as invalid. 
    #Can't check if soultion is more efficient if value is 0
    #see test/var $newValueFewerCoins
    For($i = 1; $i -le $Amount; $i++)
    {
        $table[$i] = [int32]::MaxValue
    }

    #check all amounts from 1 to amount
    For($i = 1; $i -le $Amount; $i++)
    {
        #loop thru each coin smaller than i
        For($j = 0; $j -lt $numberOfCoins; $j++)
        {
            $currentCoin = $Coins[$j]
            $keyName = "C-{0}" -f $currentCoin

            If($currentCoin -le $i)
            {
                #store results of previous subproblem
                $subResult = $table[$i-$currentCoin]
                $subHash = $results[$i - $currentCoin]

                $validSubResult = $subResult -ne [int32]::MaxValue
                $newValueFewerCoins =  ($subResult + 1) -lt $table[$i]
                If($validSubResult -and $newValueFewerCoins)
                {
                    $table[$i] = $subResult + 1
                    $results[$i] = $subHash.Clone()
                    $results[$i][$keyName] = $subHash[$keyName] + 1
                }
            }
        }
    }

    #$table[$Amount]
    [PSCustomObject]$results[$Amount] 
}

Make-Change -Amount 48 -Coins 25,24,5,1
Make-Change -Amount 50 -Coins 25,10,5,1
Make-Change -Amount 61 -Coins 25,10,5,1