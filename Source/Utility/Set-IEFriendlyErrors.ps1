
  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'Medium')]
  param([string]$SetTo = "NO")

  process {
	if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME,"Change Friendly Http Errors?")) {

	  $regpath = "HKCU:\Software\Microsoft\Internet Explorer\Main"
	  $regproperty = "Friendly http errors"
	  $currValue = (Get-ItemProperty -Path $regpath | select -ExpandProperty $regproperty)

	  Write-Verbose "Current value of '$regpath\$regproperty' is $currValue"
	  if ($currvalue.ToUpper() -ne $SetTo) {
		Write-Verbose "Setting  '$regpath\$regproperty' to $SetTo"
		Set-ItemProperty -Path $regpath -Name $regproperty -Value $SetTo
	  } else { Write-Verbose "'$regpath\$regproperty' is already $SetTo, taking no action." }

	}
  }

