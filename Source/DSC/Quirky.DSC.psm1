#
# Quirky.psm1
#

function Get-DSCConfigDetailsPath ()
{
  [CmdletBinding()]
  param(
	[Parameter(Mandatory = $true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string[]]$ComputerName,
	[Parameter(Mandatory = $true)]
	[string]$MofPath,
	[switch]$Quiet,
	[switch]$DisplayOnly,
	[switch]$TestOnly)


  begin
  {
	Set-StrictMode -Version Latest



	function Get-ConfigStatus
	{
	  [CmdletBinding()]
	  param(
		[Parameter(Mandatory = $true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
		[string]$ComputerName,
		[string]$MofPath,
		[switch]$Quiet)

	  $paddedComputer = $ComputerName.padRight(16)
	  Write-Verbose "Test-DscConfiguration -ComputerName $computer -Path $mofPath -ErrorAction SilentlyContinue"
	  $results = Test-DscConfiguration -ComputerName $computer -Path $mofPath -ErrorAction SilentlyContinue
	  if (-not $Quiet)
	  {
		Write-Host ""
		Write-Host "$paddedComputer Configuration: $(Split-Path $mofPath -Leaf) ($mofPath)"
	  }

	  if ($results -ne $null -and (-not $Quiet))
	  {

		foreach ($ids in $results.ResourcesInDesiredState)
		{

		  $paddedConfiguration = $ids.ResourceID.padRight(40)
		  Write-Host "  $paddedConfiguration In Desired State"
		}
		foreach ($nds in $results.ResourcesNotInDesiredState)
		{
		  $paddedConfiguration = $nds.ResourceID.padRight(40)
		  Write-Host "  $paddedConfiguration " -NoNewline
		  Write-Host "NOT In Desired State" -ForegroundColor Red
		}
		Write-Host ""

	  } else {
		if (-not $Quiet)
		{

		  Write-Host "$($error[0].ToString())" -ForegroundColor Red
		  Write-Host ""
		}

	  }
	  return $results
	}
	if (-not (Test-Path $mofPath)) { throw "Can't find $mofPath" }
	$mofRoot = (Get-Item $mofPath).FullName

	$returnValues = @()

  }

  process
  {
	if (-not (Test-Path -Path $mofRoot -PathType Container)) { throw "Invalid Path $mofRoot" }
	foreach ($Computer in $ComputerName)
	{

	  [hashtable]$theseResults = @{}
	  $theseResults.ComputerName = $computer
	  $theseResults.StatusInfo = @()

	  if (Test-Connection -ComputerName $Computer -Quiet -ErrorAction SilentlyContinue)
	  {

		$runFirst = $(Join-Path $MofRoot 'runfirst')
		if (Test-Path $(Join-Path $runFirst "$computer.mof"))
		{
		  $results = (Get-ConfigStatus $Computer $runFirst -Quiet:$Quiet -Verbose:$VerbosePreference)
		  [hashtable]$info = @{}
		  if ($results -ne $null)
		  {

			$info.ConfigName = (Split-Path $runFirst -Leaf)
			$info.InDesiredState = $results.InDesiredState
			$info.StatusInfo = $results
		  }
		  $infoObject = New-Object -Type PSObject -Property $info
		  $theseResults.StatusInfo += $infoObject

		} else {
		  if (-not $Quiet) { Write-Host "No config for $computer at $runFirst" }
		}


		$mofFolders = (Get-ChildItem -Path $MofRoot -Directory -Exclude 'runfirst')
		if ($mofFolders -eq $null)
		{
		  $mofFolders = Get-Item $mofRoot
		}

		foreach ($folder in $mofFolders.FullName)
		{
		  if (Test-Path $(Join-Path $folder "$computer.mof"))
		  {
			$results = (Get-ConfigStatus $computer $folder -Quiet:$Quiet)
			[hashtable]$info = @{}
			$info.ConfigName = (Split-Path $folder -Leaf)
			$info.InDesiredState = $false
			$info.StatusInfo = $null

			if ($results -ne $null -and ($results.PSObject.Properties.Name -match "InDesiredState"))
			{
			  $info.InDesiredState = $results.InDesiredState
			  $info.StatusInfo = $results
			}
			$infoObject = New-Object -Type PSObject -Property $info
			$theseResults.StatusInfo += $infoObject
		  } else { if (-not $Quiet) { Write-Host "No config for $computer at $folder" } }

		}

	  }
	  $resultsObject = New-Object -Type PSObject -Property $theseResults
	  $returnValues += $resultsObject

	}

  }

  end
  {
	if ($DisplayOnly) { $returnValues = $null }
	return,$returnValues
  }
}


function Get-DSCConfigStatus ()
{
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
	  if ($session -eq $null)
	  {
		$session = New-CimSession -ComputerName $computer
	  }

	  if ($session -eq $null) { throw "Can't create session on $computer" }
	  $allresults = Get-DscConfigurationStatus -CimSession $session -All:$All
	  Remove-CimSession -CimSession $Session

	  if ($allresults -ne $null) {
		foreach ($results in $allresults)
		{
		  if (-not $Quiet)
		  {
			$paddedComputer = $computer.padRight(16)

			Write-Host ""
			Write-Host "$paddedComputer Configuration: $($results.Status) Type: $($results.Type) Reboot Needed: $($results.RebootRequested)"
			if ($results.NumberOfResources -ne $null -and $results.NumberOfResources -gt 0)
			{

			  foreach ($ids in $results.ResourcesInDesiredState)
			  {
				if ($ids -ne $null) {
				  $paddedConfiguration = $ids.ResourceID.padRight(40)
				  Write-Host "  $paddedConfiguration In Desired State"
				}

			  }
			  foreach ($nds in $results.ResourcesNotInDesiredState)
			  {

				if ($nds -ne $null)
				{


				  $outputString = "Config Unknown "
				  if($nds.ResourceId -ne $null){$outputString = $nds.ResourceId}



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
}

function Stop-PendingDSCConfiguration ()
{
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
}


function Remove-WSManShells
{
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


}
function Show-WSManShells
{
  param([string[]]$ComputerName = "localhost",
	[string[]]$UserName)
  $results = @()
  foreach ($computer in $ComputerName)
  {
	if (Test-Connection -ComputerName $Computer -Quiet)
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

}

Function Get-DSCResourcesInModule ()
{
[CmdletBinding()]
param([string[]]$ModuleName)

begin
{}

process
{
foreach($thisModuleName in $ModuleName){
 $dscResource = $(Get-DSCResource -Module $thisModuleName -ErrorAction SilentlyContinue)
		if($dscResource -ne $null)
		{
		  $modByName = @{}
		  $modbyName.Name = $thisModuleName
		  $modbyName.Properties = new-object 'System.Collections.Generic.Dictionary[string,Object]'

		  foreach($r in $dscResource)
		  {
			$thisItem = @{}
			$thisItem.Name = $r.Name
			$thisItem.CommandType = "DSCResource"
			$thisObject =  $(New-Object -Type PSObject -Property $thisItem)
			$modbyName.ExportedCommands.Add($thisItem.Name,$thisObject)
		  }
		}
		}
}

end
{
}
}


Function Get-DSCFunctions ()
{
  param($IncludeAzure)

  if($IncludeAzure){
	Get-Command *DSC*
  }else{
	Get-Command *DSC*|Where {-not ($_.Source -match 'Azure')}
  }
}
Set-Alias dscfunc -value Get-DSCFunctions



function Show-DSCConfigurationComplete ()
{
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
}
