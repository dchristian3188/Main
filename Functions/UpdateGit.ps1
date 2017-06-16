[CmdletBinding()]
param(
    [Parameter()]
    [Switch]
    $Push
)


$repos = Get-ChildItem -Path $PSScriptRoot -Directory

foreach ($repo in $repos)
{
    Write-Host -ForegroundColor Green -Object "Updating Git Repo: [$($repo.BaseName)]"
    Push-Location -Path $repo.FullName
    & git pull
    if($Push)
    {
        & git push
    }
    Pop-Location
}