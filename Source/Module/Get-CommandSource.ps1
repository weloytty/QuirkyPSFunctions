
  [CmdletBinding()]
  param(
	[Alias('Name')]
	[Parameter(Mandatory = $true)]
	[string]$CommandToFind,
	[switch]$Details
  )
  $a = Get-Command $CommandToFind -ErrorAction SilentlyContinue
  if ($a -ne $null)
  {
	$article = 'a'
	if ($a.CommandType -eq 'Alias' -or $a.CommandType -eq 'Application') { $article = 'an' }
	Write-Verbose "$CommandToFind is $article $($a.CommandType)"
	switch ($a.CommandType)
	{
	  "Application" { $output = $a.Source }
	  "CmdLet" { $output = $a.Source }
	  "Filter" { $output = $a.Source }
	  "ExternalScript" { $output = $a.Source }
	  "Alias" {
		$def = $a | Select-Object -ExpandProperty Definition
		Write-Verbose "$CommandToFind is an alias for $def"
		if ($def -ne $null)
		{
		  $output = Get-CommandSource -CommandToFind $def -Details:$Details
		}

	  }
	  default { $output = $a.Source }
	}
	Write-Output $output
  }


