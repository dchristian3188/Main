#shamelessly stolen from https://powershellstation.com/2017/04/19/generating-case-combinations-powershell/
function Get-StringCases
{
    param(
        [string]
        $InputString
    )
 
    $vars = $InputString.ToLower() , $InputString.ToUpper() 
 
    $powers = 0..$InputString.length | ForEach-Object {  [math]::pow(2, $_) }
    $total = ([math]::Pow(2, $InputString.length) - 1)
    foreach ($i in 0..$total)
    {
        (0..($InputString.length - 1)|ForEach-Object {$vars[($i -band $powers[$_]) / $powers[$_]][$_]}) -join ''
    } 
}