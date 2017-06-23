
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true)]
	[string[]]$ComputerName = $env:computername
  )
  begin {

	$CommandsToRun = {
	  Remove-Item $env:systemRoot/system32/configuration/pending.mof -Force;
	  Get-Process *wmi* | Stop-Process -Force;
	  Restart-Service winrm -Force
	}
  }

  process
  {
	foreach ($computer in $computername)
	{
	  $psVersion = $(Invoke-Command -ComputerName $computer { $PSVersionTable }).PSVersion.Major

	  if ($PSVersion -eq "6")
	  {
		$CimSession = New-CimSession -ComputerName $computer
		Stop-DscConfiguration -CimSession $CimSession -Force
		Remove-CimSession -Session $CimSession

	  } else
	  {
		Invoke-Command -ComputerName $computer -ScriptBlock $CommandsToRun
	  }
	}
  }

