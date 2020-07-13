[CmdletBinding()]
	<#
	.SYNOPSIS
    Restarts services related to RDP.
	.DESCRIPTION
		Restarts services related to RDP: 'TermService' and 'Remote Desktop Services UserMode Port Redirector' 
	.PARAMETER ComputerName
    ComputerName that will have it RDP related services restarted.
	.EXAMPLE	
    Nuke-RDP -ComputerName 'Contoso1'
	#>
  param([string]$ComputerName = throw 'Need to supply ComputerName')
  Get-Service -ComputerName $ComputerName -Name 'Remote Desktop Services UserMode Port Redirector' | Stop-Service -Force -Verbose
  Get-Service -ComputerName $ComputerName -Name 'TermService' | Stop-Service -Force -Verbose
  Get-Service -ComputerName $ComputerName -Name 'TermService' | Start-Service -Verbose
  Get-Service -ComputerName $ComputerName -Name 'Remote Desktop Services UserMode Port Redirector' | Start-Service -Verbose
