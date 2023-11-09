
[CmdletBinding()]
param([string[]]$ComputerName,
	[switch]$ViewOnly,
	[switch]$OverWriteAll,
	[switch]$Force)

begin {
	Set-StrictMode -Version Latest
}
process {

	if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		if (Test-Path wsman::localhost\client\trustedhosts) {
			$currentValue = (Get-Item -Path wsman::localhost\client\TrustedHosts).Value

			Write-Verbose "Current Value is $currentValue"

			if ($OverWriteAll) { $currentValue = $null }

			$newItems = @()

			if ($null -ne $currentValue -and $currentValue.Length -gt 0) {
		  $currentItemsMessage = "Current Trusted Hosts:"
		  if ($VerbosePreference -and (-not $ViewOnly)) {
					Write-Verbose $currentItemsMessage
		  } else {
					Write-Output $currentItemsMessage
		  }
		  foreach ($s in $currentValue.Split(',')) {
					if (($s.Length -gt 0) -and (-not $newItems.Contains($s))) { $newItems += $s }
			
					if ($VerbosePreference -and (-not $ViewOnly)) {
						Write-Verbose $s
					} else {
						Write-Output $s
					}
		  }
			}
			if (-not $ViewOnly) {
		  foreach ($item in $ComputerName) {
					if (-not $newItems.Contains($item)) {
						$newItems += $item
					}
		  }

		  if ($newItems.Length -gt 0) {

					Write-Verbose "Old Value: $currentValue"
					if ($newItems.Length -gt 1)
					{ [string]$newString = [string]::Join(",", $newItems) } else { $newString = $newItems }

					Write-Verbose "New Value: $newString"
					if ($ComputerName.Contains('*') -or $newItems.Contains('*')) { $newString = '*' }
					if ($Force -or (-not $ViewOnly -and ($newString -ne $currentValue))) {
						Write-Verbose "Set-Item wsman::localhost\client\trustedhosts -value $newString -Force"
						Set-Item wsman::localhost\client\trustedhosts -Value $newString -Force
					}
		  }
			}
		}
	} else { Write-Error "No admin rights. Run elevated." }

}


