
  param([string[]]$ComputerName = "localhost",
	[string[]]$UserName)
  $results = @()
  foreach ($computer in $ComputerName)
  {
	if (Test-NetConnection -ComputerName $Computer -InformationLevel Quiet)
	{
	  $shells = Get-WSManInstance -ConnectionUri "http:`/`/$($Computer):5985/wsman" shell -enum
	  $results = $shells
	  if ($UserName -ne $null -and $UserName.Length -gt 0) { $results = $null }
	  foreach ($user in $UserName)
	  {
		$results += $($shells | Where-Object { $_.Owner -eq $user })
	  }

	} else { Write-Output "Can't connect to $computer" }

  }
  return $results


