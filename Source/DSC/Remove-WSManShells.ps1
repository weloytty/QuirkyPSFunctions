
  param(
	[Alias("Computer")]
	[Parameter(Mandatory = $true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string]$ComputerName,
	[Parameter(ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string[]]$ShellID,
	[string[]]$UserName
  )

  if (Test-Connection -Computer $computerName -Quiet)
  {

	foreach ($user in $UserName)
	{
	  Write-Verbose "Closing shells for $user"
	  $shells = (Get-WSManInstance -ConnectionUri "http:`/`/$($ComputerName):5985/wsman" shell -enum | Where-Object { $_.Owner -eq $user })
	  foreach ($s in $shells.ShellId)
	  {
		Write-Verbose "Closing Shell with id $s "
		Remove-WSManInstance -ConnectionUri "http:`/`/$($ComputerName):5985/wsman" shell @{ ShellId = $s }
	  }
	}
	foreach ($sid in $ShellID)
	{
	  Write-Verbose "Closing shell $ShellID"
	  Remove-WSManInstance -ConnectionUri "http:`/`/$($ComputerName):5985/wsman" shell @{ ShellId = $sid }
	}

  }



