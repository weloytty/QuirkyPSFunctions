
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true)]
	[string[]]$ComputerName = $env:computername,
	[switch]$Quiet,
	[switch]$DisplayOnly,
	[switch]$All
  )

  begin {
	Set-StrictMode -Version Latest
  $returnValue = @()
  }
  process
  {
	foreach ($computer in $ComputerName)
	{
	  $session = Get-CimSession -ComputerName $Computer -ErrorAction SilentlyContinue
        if ($null -ne $session)
	  {
		$session = New-CimSession -ComputerName $computer
	  }

	  if ($null -eq $session) { throw "Can't create session on $computer" }
	  $allresults = Get-DscConfigurationStatus -CimSession $session -All:$All
	  Remove-CimSession -CimSession $Session

	  if ($null -ne $allresults) {
		foreach ($results in $allresults)
		{
		  if (-not $Quiet)
		  {
			$paddedComputer = $computer.padRight(16)

			Write-Host ""
			Write-Host "$paddedComputer Configuration: $($results.Status) Type: $($results.Type) Reboot Needed: $($results.RebootRequested)"
			if ($null -ne $results.NumberOfResources -and $results.NumberOfResources -gt 0)
			{

			  foreach ($ids in $results.ResourcesInDesiredState)
			  {
				if ($null -ne $ids) {
				  $paddedConfiguration = $ids.ResourceID.padRight(40)
				  Write-Host "  $paddedConfiguration In Desired State"
				}

			  }
			  foreach ($nds in $results.ResourcesNotInDesiredState)
			  {

				if ($null -ne $nds)
				{


				  $outputString = "Config Unknown "
				  if($null -ne $nds.ResourceId){$outputString = $nds.ResourceId}



				  $paddedConfiguration = $outputString.padRight(40)
				  Write-Host "  $paddedConfiguration " -NoNewline
				  Write-Host "NOT In Desired State" -ForegroundColor Red


				}
				#Write-Host ""
			  }

			}


		  }
		  $returnValue += $results
		}

	  }


	}


  }
  end
  {
	if ($DisplayOnly) { $results = $null }
	return,$returnValue
  }

