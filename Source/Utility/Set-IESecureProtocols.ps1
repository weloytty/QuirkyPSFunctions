
  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'Medium')]
  param([int]$SetTo = 0x00000aa0)

  process {
	if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME,"Change Friendly Http Errors?")) {


	  $regpath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
	  $regproperty = "SecureProtocols"
	  $currValue = (Get-ItemProperty -Path $regpath | select -ExpandProperty $regproperty)

	  Write-Verbose "Current value of '$regpath\$regproperty' is $currValue"
	  if ($currvalue -ne $SetTo) {
		Write-Verbose "Setting  '$regpath\$regproperty' to $SetTo"
		Set-ItemProperty -Path $regpath -Name $regproperty -Value $SetTo
	  } else { Write-Verbose "'$regpath\$regproperty' is already $SetTo, taking no action." }

	}
  }

