function Replace-DCFilename
{
	<#

		.SYNOPSIS

		Its like a super Repalce for a for files

		.PARAMETER OldString

		$OldString The String that is being Replaced
		
		.PARAMETER NewString

		$NewString The String that is being doing the replacing
		
		.PARAMETER InputLoc

		$InputLoc What Directory are we running this on. Defaults to current Location
	
		
		.EXAMPLE
		
		Replace-DCFilename "cats" "dogs"
				

	#>
	[cmdletBinding()]
	Param
	(
		
		[String]$OldString = $(Throw ‘$OldString is required’),
		[String]$NewString = "",
		$InputLoc = (Get-Location)
	)
	Begin
	{
		
		
		$files = Get-ChildItem -LiteralPath $inputLoc -Recurse | 
			Where-Object {$PSItem.Name -match $OldString}
		if($files.Length -gt 0)
		{
			Write-Host "Lets Rock"
			Write-Host "Changing:"
		}
	}
	PROCESS 
	{	
		foreach($file in $files)
		{
			$tempName = $file.Name.Replace($OldString,$NewString)
			$tempPath = $file.FullName.Replace($file.Name,$tempName)
			Write-Host "$file -> $tempName"
			Rename-Item -LiteralPath $file.FullName $tempPath
		}
	}
	End
	{
		Write-Host "All Done"
	}
}