
[CmdletBinding()]
param([string[]]$ComputerName)


$params = @{
	 Namespace  = 'root/Microsoft/Windows/DesiredStateConfiguration'
	 ClassName  = 'MSFT_DSCLocalConfigurationManager'
	 MethodName = 'PerformRequiredConfigurationChecks'
	 Arguments  = @{
		Flags   = [uint32] 1
	 }
 }

 Invoke-CimMethod @params -Computername $ComputerName

