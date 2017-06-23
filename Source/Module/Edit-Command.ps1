
  [CmdletBinding()]
  param(
	[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true)]
	[string]$CommandName
  )
  begin
  {
	Set-StrictMode -Version Latest
  }

  process
  {

	$file = Find-CommandSourceCode -Name $CommandName -Verbose:$VerbosePreference
	Write-Verbose "Find-CommandSource returned '$file'"
	if ($file.Path -ne '' -and $file.Path -ne $null)
	{
	  Edit-File -FileName "$($file.Path)" -Verbose:$VerbosePreference
	} else { Write-Error "Can't find source for $CommandName" }

  }

