
  [CmdletBinding()]
  param(
	[Parameter(Mandatory = $true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string[]]$FileName,
	[switch]$Quiet
  )

  begin
  {
	Set-StrictMode -Version Latest
	$returnValue = @()
  }

  process
  {
	foreach ($file in $FileName)
	{
	  if (Test-Path $file -PathType Leaf)
	  {
		$item = Get-Item $file | Select -ExpandProperty FullName
		[hashtable]$results = @{}
		$results.Name = $(Get-Item $item | Select -ExpandProperty Name)
		$results.FullName = $item
		$results.Parses = $false
		$tokens = $null
		$parseErrors = $null
		Write-Host $item

		$ast = [System.Management.Automation.Language.Parser]::ParseFile($item,[ref]$tokens,[ref]$parseErrors)
		foreach ($err in $parseErrors)
		{
		  Write-Host $err
		}
		$results.Tokens = $tokens
		$results.ParseErrors = $parseErrors
		if ($parseErrors.Count -eq 0)
		{
		  $results.Parses = $true
		}
		if ($Quiet)
		{
		  $returnValue += $results.Parses
		} else {
		  $returnValue += New-Object -Type PSObject -Property $results
		}



	  }
	}
  }

  end
  {
	return $returnValue
  }


