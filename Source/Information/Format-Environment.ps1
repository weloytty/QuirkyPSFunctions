
  [CmdletBinding()]
  param(
	[Parameter(Mandatory = $true,ValueFromPipeline = $true)]
	[string]$EnvironmentPath
  )
  process {
	$a = Get-ChildItem env:$EnvironmentPath

	foreach ($s in $a.Value.Split(";")) { $s }
  }

