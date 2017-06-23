
  [CmdletBinding()]
  param(
	[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true)]
	[string]$VariableName,
	[ValidateSet('User','Machine')]
	[string]$Scope = 'User'
  )

  process {
	$returnValue = ""
	if ($VariableName.Contains('%'))
	{
	  $returnValue = [string][System.Environment]::ExpandEnvironmentVariables($VariableName)
	} else {
	  $returnValue = [environment]::GetEnvironmentVariable($VariableName,$Scope)

	}
	return $returnValue
  }

