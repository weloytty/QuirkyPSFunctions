#
# PersonalFunctions.psm1
#
function Test-NeedsReboot {
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true,Position = 0)]
	[string[]]$ComputerName = $($env:computername),
	[switch]$DisplayOnly,
	[switch]$Quiet)
  begin {
	$SB = {
	  $VerbosePreference = $using:VerbosePreference
	  $paddedComputer = $env:ComputerName.padRight(15)

	  $ComponentBasedServicing = $false
	  $cbsValue = (Get-ChildItem 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\').Name
	  if ($cbsValue -ne $null) {
		$ComponentBasedServicing = $cbsValue.Split("\") -contains "RebootPending"
	  }

	  Write-Verbose "ComponentBasedServicing is $ComponentBasedServicing"

	  $WindowsUpdate = $false
	  $wuValue = (Get-ChildItem 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\').Name
	  if ($wuValue -ne $null) {
		$WindowsUpdate = $wuValue.Split("\") -contains "RebootRequired"
	  }

	  Write-Verbose "WindowsUpdate is $WindowsUpdate"

	  $renameOps = $(Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\').PendingFileRenameOperations

	  $PendingFileRename = ($renameOps.Length -gt 0)
	  Write-Verbose "PendingFileRename is $PendingFileRename"
	  if ($VerbosePreference -and $PendingFileRename) {
		Write-Verbose ""
		Write-Verbose "Pending File Rename Operations"
		for ($i = 0; $i -lt $renameOps.Length; $i++) {
		  if ($renameOps[$i].Length -gt 0) {
			Write-Verbose $renameOps[$i]
		  }
		}
		Write-Verbose ""
	  }
	  $ActiveComputerName = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName').ComputerName
	  Write-Verbose "ActiveComputerName is $ActiveComputerName"
	  $PendingComputerName = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName').ComputerName
	  Write-Verbose "PendingComputerName is $PendingComputerName"
	  $PendingComputerRename = $ActiveComputerName -ne $PendingComputerName
	  Write-Verbose "PendingComputerRename is $PendingComputerRename"

	  $reason = "Cause:"

	  if ($ComponentBasedServicing) {
		$reason = "$reason [ComponentServicing] "
	  }
	  if ($WindowsUpdate) {
		$reason = "$reason [WindowsUpdate] "
	  }
	  if ($PendingFileRename) {
		$reason = "$reason [File Rename] "
	  }
	  if ($PendingComputerRename) {
		$reason = "$reason [Computer Rename]"
	  }

	  $needsReboot = ($ComponentBasedServicing -or $WindowsUpdate -or $PendingFileRename -or $PendingComputerRename)

	  if (-not $needsReboot) {
		$reason = ""
	  }
	  if (-not $using:Quiet) {
		Write-Output "$PaddedComputer needs reboot: $needsReboot $reason"
	  }
	  if ($using:DisplayOnly) {
		$needsReboot = $null
	  }
	  return $needsReboot

	}

  }

  process {

	foreach ($Computer in $ComputerName) {
	  if (Test-Connection $computer -Quiet -Count 1) {

		Invoke-Command -ComputerName $computer -ScriptBlock $SB

	  } else {
		Write-Output "$($Computer.PadRight(15)) not available"
	  }



	}
  }
}



function Get-WindowsPID {
	[CmdLetBinding()]
	param ([string[]]$ComputerName = @("."))
	$hklm = 2147483650
	$regPath = "Software\Microsoft\Windows NT\CurrentVersion"
	$regValue = "DigitalProductId"
	Foreach ($target in $ComputerName) {
		$productKey = $null
		$win32os = $null
		$wmi = [WMIClass]"\\$target\root\default:stdRegProv"
		$data = $wmi.GetBinaryValue($hklm,$regPath,$regValue)
		$binArray = ($data.uValue)[52..66]
		$charsArray = "B","C","D","F","G","H","J","K","M","P","Q","R","T","V","W","X","Y","2","3","4","6","7","8","9"
		## decrypt base24 encoded binary data
		For ($i = 24; $i -ge 0; $i--) {
			$k = 0
			For ($j = 14; $j -ge 0; $j--) {
				$k = $k * 256 -bxor $binArray[$j]
				$binArray[$j] = [math]::truncate($k / 24)
				$k = $k % 24
			}
			$productKey = $charsArray[$k] + $productKey
			If (($i % 5 -eq 0) -and ($i -ne 0)) {
				$productKey = "-" + $productKey
			}
		}
		$win32os = Get-WmiObject Win32_OperatingSystem -computer $target
		$obj = New-Object Object
		$obj | Add-Member Noteproperty Computer -value $target
		$obj | Add-Member Noteproperty Caption -value $win32os.Caption
		$obj | Add-Member Noteproperty CSDVersion -value $win32os.CSDVersion
		$obj | Add-Member Noteproperty OSArch -value $win32os.OSArchitecture
		$obj | Add-Member Noteproperty BuildNumber -value $win32os.BuildNumber
		$obj | Add-Member Noteproperty RegisteredTo -value $win32os.RegisteredUser
		$obj | Add-Member Noteproperty ProductID -value $win32os.SerialNumber
		$obj | Add-Member Noteproperty ProductKey -value $productkey
		$obj
	}
}

function Get-InstalledApplication {
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipelineByPropertyName = $true,Position = 0)]
	[string[]]$ComputerName = $env:COMPUTERNAME,
	[string]$AppName,
	[string]$Publisher,
	[switch]$Quiet

  )

  begin {
	Set-StrictMode -Off

	$results = $()

	$SB = {
	  $VerbosePreference = $using:VerbosePreference

	  $Quiet = $using:Quiet

	  $returnValues = @()
	  $foundPackages = 0

	  if ((Get-WmiObject win32_operatingsystem).OSArchitecture -notlike '64-bit') {
		$RegistryLocations = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')
	  }
	  else {
		$RegistryLocations = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',`
			 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' `
		  )
	  }

	  $totalIncludingNull = $($RegistryLocations.Count)
	  $locationsToProcess = $($registryLocations | Where-Object { $_.PSChildName -or $_.Publisher -or $_.UninstallString -or $_.displayversion -or $_.DisplayName })


	  $Activity = "Processing Uninstall information on $($env:ComputerName)"
	  $TotalItems = $locationsToProcess.Length
	  $CurrentItem = 0
	  foreach ($location in $locationsToProcess) {
		$CurrentItem++
		[int]$percentComplete = (($currentItem / $totalItems) * 100)
		Write-Progress -Activity $Activity -Status "$percentComplete% Complete" -PercentComplete $percentComplete
		$foundPackages++
		$thisPublisher = "NULL"
		$thisVersion = "NULL"
		$thisProduct = "NULL"
		$thisUninstallString = "NULL"
		$thisChildName = "NULL"

		if ($location.Publisher) {
		  $thisPublisher = $location.Publisher
		}
		if ($location.displayversion) {
		  $thisVersion = $location.displayversion
		}
		if ($location.DisplayName) {
		  $thisProduct = $location.DisplayName
		}
		if ($location.UninstallString) {
		  $thisUninstallString = $location.UninstallString
		}
		if ($location.PSChildName) {
		  $thisChildName = $location.PSChildName
		}

		if (($thisPublisher -eq "NULL") -and `
			 ($thisVersion -eq "NULL") -and `
			 ($thisProduct -eq "NULL") -and `
			 ($thisChildName -eq "NULL") -and `
			 ($thisUninstallString -eq "NULL")) {
		  $skippedPackages++
		  if (-not ($Quiet)) {
			Write-Host "Skipping $location"
		  }
		} else {
		  [hashtable]$thisPackage = @{}

		  $thisPackage.ComputerName = "$env:COMPUTERNAME"
		  $thisPackage.Publisher = $thisPublisher
		  $thisPackage.Version = $thisVersion
		  $thisPackage.Product = $thisProduct
		  $thisPackage.PSChildName = $thisChildName
		  $thisPackage.UninstallString = $thisUninstallString
		  $thisObject = New-Object -Type psobject -Property $thisPackage
		  $returnValues += $thisObject
		  $thisPackage = $null
		}
	  }
	  if (-not ($Quiet)) {
		Write-Verbose "Total Records: $totalIncludingNull"
		Write-Verbose "Records to process: $TotalItems"
		Write-Verbose "Processed $CurrentItem, Skipped $($totalIncludingNull - $TotalItems)"
	  }
	  Write-Progress -Activity $Activity -Completed
	  return,$returnvalues



	}
  }
  process {

	foreach ($computer in $computername) {
	  Write-Verbose "Getting applications on $computer running from $($env:computername)"

	  $packages = $(Invoke-Command -ComputerName $computer -ScriptBlock $SB -EnableNetworkAccess)

	  $results += $packages
	}


  }
  end {
	$publisherResults = $null
	$appresults = $null
	if ($Publisher -ne "") {
	  Write-Verbose "Selecting Publisher $Publisher"
	  $publisherResults = $results | Where-Object { $_.Publisher -match $Publisher }
	  Write-Verbose "There are $($publisherResults.Length) results for publisher  $Publisher"
	}
	if ($AppName -ne "") {
	  Write-Verbose "Selecting Application $AppName"
	  $appResultsResults = $results | Where-Object { $_.Product -match $AppName }
	  Write-Verbose "There are $($appResultsResults.Length) results for application $appname"
	}
	Write-Verbose "Appresults is null: $($Appresults -eq $null)"
	Write-Verbose "Publisher Results is null: $($publisherResults -eq $null)"
	if (($AppName -ne "") -or ($Publisher -ne "")) {
	  $results = $publisherResults + $appResultsResults
	}


	return $results

  }
}


function Get-SystemUptime {
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string[]]$ComputerName = $(hostname),
	[switch]$DisplayOnly,
	[switch]$Quiet)


  begin
  {
	$returnValues = @()

	if ($Quiet -and $DisplayOnly) {
	  Write-Verbose "Quiet and DisplayOnly were both set, no output will be produced"
	}
  }

  process
  {
	foreach ($computer in $ComputerName) {
	  if (Test-Connection -Quiet -Count 1 -ComputerName $computer)
	  {
		$operatingSystem = Get-WmiObject Win32_OperatingSystem -ComputerName $computer;
		#"$((Get-Date) - ([Management.ManagementDateTimeConverter]::ToDateTime($operatingSystem.LastBootUpTime)))";
		$LastBootUpTime = $([Management.ManagementDateTimeConverter]::ToDateTime($operatingSystem.LastBootUpTime))
		$timeDiff = New-TimeSpan $LastBootUpTime $(Get-Date)
		$differenceOutput = '{0:00} Days {1:00} hours {2:00} minutes {3:00} seconds' -f $timeDiff.Days,$timeDiff.Hours,$timeDiff.Minutes,$timeDiff.Seconds
		if (-not $Quiet)
		{
		  Write-Host "$($computer.padRight(15)) $differenceOutput"
		}

		if (-not $DisplayOnly) {
		  $thisValue = $(New-Object -Type PSObject -Property @{ ComputerName = $computer; TimeSpanSinceBoot = $timeDiff })
		  $returnValues += $thisValue
		}


	  } else { Write-Verbose "Can't connect to $computer" }
	}
  }

  end
  {
	return $returnValues
  }



}

function Get-BootTime {
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string[]]$ComputerName = $env:COMPUTERNAME,
	[switch]$DisplayOnly,
	[switch]$Quiet)

  begin {

	$returnValues = @()
  }

  process {

	Write-Verbose "Display Only is set to $DisplayOnly"
	Write-Verbose "Quiet is set to $Quiet"

	if ($Quiet -and $DisplayOnly) {
	  Write-Verbose "Quiet and DisplayOnly were both set, no output will be produced"
	}


	foreach ($s in $computername) {
	  $results = $null
	  $results = Get-WmiObject win32_operatingsystem -ComputerName $s -ErrorAction SilentlyContinue #| Select @{ LABEL = 'ComputerName   .'; Expression = { $s } },@{ LABEL = 'LastBootUpTime     .'; Expression = { $_.ConverttoDateTime($_.lastbootuptime) } }
	  $paddedName = $s.padRight(15)
	  $bootedTime = "(server unavailable)"
	  if ($results -ne $null) {
		$bootedTime = $results.ConverttoDateTime($results.LastBootUpTime)
	  }

	  if (-not $Quiet) {

		Write-Output "$paddedName was last booted $bootedTime"
	  }
	  if (-not $DisplayOnly) {
		$thisValue = $(New-Object -Type PSObject -Property @{ ComputerName = $s; BootTime = $bootedTime })
		$returnValues += $thisValue
	  }


	}

  }
  end {

	return $returnValues
  }
}

function Get-DotNetVersion () {
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
	[string[]]$ComputerName = $env:COMPUTERNAME,
	[switch]$DisplayOnly,
	[switch]$Quiet)

  begin {
	Write-Verbose "Entering Begin block"
	$ScriptToRun = {


	  $VerbosePreference = $using:VerbosePreference

	  Write-Verbose "In Script Block"
	  Write-Verbose "Display Only is set to $($using:DisplayOnly)"
	  Write-Verbose "Quiet is set to $($using:Quiet)"

	  if ($using:Quiet -and $using:DisplayOnly) {
		Write-Verbose "Quiet and DisplayOnly were both set, no output will be produced"
	  }

	  $regKey = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\"

	  $clrVersion = Get-ItemProperty $regKey | Select-Object Version -ErrorAction SilentlyContinue
	  $release = Get-ItemProperty $regKey | Select-Object Release -ErrorAction SilentlyContinue

	  Write-Verbose "Value of Release is $($release)"

	  switch ($release.Release) {
		378389 {
		  $versionName = ".NET Framework 4.5"
		}
		378675 {
		  $versionName = ".NET Framework 4.5.1 installed with Windows 8.1 or Windows Server 2012 R2"
		}
		378758 {
		  $versionName = ".NET Framework 4.5.1 installed on Windows 8, Windows 7 SP1, or Windows Vista SP2"
		}
		379893 {
		  $versionName = ".NET Framework 4.5.2"
		}
		393295 {
		  $versionName = ".NET Framework 4.6"
		}
		393297 {
		  $versionName = ".NET Framework 4.6"
		}
		394254 {
		  $versionName = ".NET Framework 4.6.1"
		}
		394271 {
		  $versionName = ".NET Framework 4.6.1"
		}
		394747 {
		  $versionName = ".NET Framework 4.6.2 Preview"
		}
		394748 {
		  $versionName = ".NET Framework 4.6.2 Preview"
		}
		default {
		  $versionName = $clrVersion.Version
		}
	  }

	  $paddedName = $($Env:COMPUTERNAME).padRight(15)
	  if ($using:Quiet -eq $false) {
		Write-Output "$paddedName is running CLR Version $($clrVersion.Version) ($versionName)"
	  }


	  [hashtable]$returnValues = @{}
	  $returnValues.ComputerName = $Env:COMPUTERNAME
	  $returnValues.Version = $clrVersion.Version
	  $returnValues.VersionName = $versionName
	  $returnObject = New-Object psobject -Property $returnValues

	  if ($using:DisplayOnly) {
		$returnObject = $null
	  }

	  return $returnObject

	}
  }
  process {

	foreach ($server in $ComputerName) {
	  Write-Verbose "Processing $server"
	  Invoke-Command -ComputerName $server -ScriptBlock $ScriptToRun

	}
  }

  end {
	Write-Verbose "Entering end block"
  }


}


function Get-WindowsVersion () {
  [CmdletBinding()]
  param(
	[Parameter(Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string[]]$ComputerName = $env:COMPUTERNAME,
	[switch]$DisplayOnly,
	[switch]$Quiet)

  begin {
	Set-StrictMode -Version Latest
	Write-Verbose "Setting Script Block"
	$SB = {
	  $VerbosePreference = $using:VerbosePreference
	  Write-Verbose "In Script Block"
	  Write-Verbose "Display Only is set to $($using:DisplayOnly)"
	  Write-Verbose "Quiet is set to $($using:Quiet)"

	  if ($using:Quiet -and $using:DisplayOnly) {
		Write-Verbose "Quiet and DisplayOnly were both set, no output will be produced"
	  }

	  $a = Get-WmiObject Win32_OperatingSystem
	  $versionNumber = $a.Version
	  $bitness = "32 bit"
	  if ([intptr]::Size -eq 8) {
		$bitness = "64 bit"
	  }


	  $Version = $a.Caption
	  $VersionNumber = $a.Version

	  $paddedName = $($Env:COMPUTERNAME).padRight(15)

	  if ($using:Quiet -eq $false) {
		Write-Output "$paddedName is running Version $VersionNumber $Version $bitness"
	  }

	  [hashtable]$returnValues = @{}
	  $returnValues.ComputerName = $Env:COMPUTERNAME
	  $returnValues.Version = $VersionNumber
	  $returnValues.VersionName = $Version
	  $returnValues.Architecture = $bitness
	  $returnObject = New-Object psobject -Property $returnValues

	  if ($using:DisplayOnly) {
		$returnObject = $null
	  }

	  return $returnObject



	}
  }
  process {

	foreach ($server in $ComputerName) {
	  Write-Verbose "Processing $server"
	  Invoke-Command -ComputerName $server -ScriptBlock $SB
	}
  }
}

function Get-PowershellVersion () {
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
	[string[]]$ComputerName = $env:COMPUTERNAME,
	[switch]$DisplayOnly,
	[switch]$Quiet)
  begin {
	$ScriptToRun = {

	  $VerbosePreference = $using:VerbosePreference
	  Write-Verbose "Running on $($env:computername)"
	  Write-Verbose "Display Only is set to $($using:DisplayOnly)"
	  Write-Verbose "Quiet is set to $($using:Quiet)"

	  if ($using:Quiet -and $using:DisplayOnly) {
		Write-Verbose "Quiet and DisplayOnly were both set, no output will be produced"
	  }

	  $paddedName = $($Env:ComputerName).padRight(15)

	  if ($using:Quiet -eq $false) {
		Write-Output "$paddedName is running Powershell Version $($PSVersionTable.PSVersion) on CLR $($PSVersionTable.CLRVersion)"
	  }

	  $returnObject = New-Object -Type psobject -Property $PSVersionTable
	  if ($using:DisplayOnly) {
		$ReturnObject = $null
	  }


	  return $returnObject
	}
  }
  process {

	foreach ($server in $ComputerName) {
	  Write-Verbose "Processing $server"
	  Invoke-Command -ComputerName $server -ScriptBlock $ScriptToRun -EnableNetworkAccess

	}
  }

}

function Get-ComputerShares () {
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string[]]$computername = $env:COMPUTERNAME,
	[ValidateNotNull()]
	[System.Management.Automation.PSCredential]
	[System.Management.Automation.Credential()]
	$Credential = [System.Management.Automation.PSCredential]::Empty)
  process {
	Write-Verbose "Processing $computername"
	foreach ($s in $computername) {

	  Get-WmiObject win32_share -ComputerName $s | Format-Table Name,Path -AutoSize
	}
  }
}
Set-Alias shares Get-ComputerShares


function Get-AdministrativeEvent {

  <#
.Synopsis
The Get-AdministrativeEvent function retrieves the last critical administrative events on a local or remote computer
.EXAMPLE
Get-AdministrativeEvent -cred (get-credential domain\admin) -ComputerName srv01 -HoursBack 1
.EXAMPLE
$cred = get-credential
Get-AdministrativeEvent -cred $cred -ComputerName srv01 -HoursBack 24 | Sort-Object timecreated -Descending | Out-Gridview
.EXAMPLE
'srv01','srv02' | % { Get-AdministrativeEvent -HoursBack 1 -cred $cred -ComputerName $_ } | Sort-Object timecreated -Descending | ft * -AutoSize
.EXAMPLE
Get-AdministrativeEvent -HoursBack 36 -ComputerName (Get-ADComputer -filter *).name | sort timecreated -Descending | Out-GridView
.EXAMPLE
Get-AdministrativeEvent -cred $cred -ComputerName 'srv01','srv02' -HoursBack 12 | Out-Gridview
.EXAMPLE
$Report = Start-RSJob -Throttle 20 -Verbose -InputObject ((Get-ADComputer -server dc01 -filter {(name -notlike 'win7*') -AND (OperatingSystem -Like "*Server*")} -searchbase "OU=SRV,DC=Domain,DC=Com").name) -FunctionsToLoad Get-AdministrativeEvent -ScriptBlock {Get-AdministrativeEvent $_ -HoursBack 3 -Credential $using:cred -Verbose} | Wait-RSJob -Verbose -ShowProgress | Receive-RSJob -Verbose
$Report | sort timecreated -descending | Out-GridView
.EXAMPLE
$Servers = ((New-Object -typename ADSISearcher -ArgumentList @([ADSI]"LDAP://domain.com/dc=domain,dc=com","(&(&(sAMAccountType=805306369)(objectCategory=computer)(operatingSystem=*Server*)))")).FindAll()).properties.name
$Report = Start-RSJob -Throttle 20 -Verbose -InputObject $Servers -FunctionsToLoad Get-AdministrativeEvent -ScriptBlock {Get-AdministrativeEvent $_ -Credential $using:cred -HoursBack 48 -Verbose} | Wait-RSJob -Verbose -ShowProgress | Receive-RSJob -Verbose
$Report | format-table * -AutoSize
.NOTES
originally gotten from
http://www.happysysadm.com/2017/03/a-powershell-function-to-rapidly-gather.html?m=1
happysysadm.com
@sysadm2010
#>

  [CmdletBinding()]
  param
  (
	# List of computers
	[Parameter(Mandatory = $true,
	  ValueFromPipeline = $true,
	  ValueFromPipelineByPropertyName = $true,
	  Position = 0)]
	[Alias('Name','CN')]
	[string[]]$ComputerName,

	# Specifies a user account that has permission to perform this action
	[Parameter(Mandatory = $false)]
	[System.Management.Automation.PSCredential]
	[System.Management.Automation.Credential()]
	$Credential = [System.Management.Automation.PSCredential]::Empty,

	#Number of hours to go back to when retrieving events
	[int]$HoursBack = 1

  )

  begin {
	Write-Verbose "$(Get-Date) - Started."
	$AllResults = @()
  }

  process {

	foreach ($Computer in $ComputerName) {
	  if (-not (Test-Connection -ComputerName $Computer -Quiet -Count 1))
	  { Write-Output "Can't connect to $Computer" } else {
		$Result = $Null
		Write-Verbose "$(Get-Date) - Working on $Computer - Eventlog"
		$starttime = (Get-Date).AddHours(- $HoursBack)

		try {
		  Write-Verbose "$(Get-Date) - Trying with Get-WinEvent"
		  $result = Get-WinEvent -ErrorAction stop -ComputerName $Computer -filterh @{ LogName = (Get-WinEvent -ComputerName $Computer -ListLog * | ? { ($_.logtype -eq 'administrative') -and ($_.logisolation -eq 'system') } | ? recordcount).LogName; StartTime = $starttime; Level = 1,2 } | select machinename,timecreated,providername,logname,id,leveldisplayname,message
		}

		catch [System.Diagnostics.Eventing.Reader.EventLogException]{
		  switch -regex ($_.Exception.Message) {
			"RPC" {
			  Write-Warning "$(Get-Date) - RPC error while communicating with $Computer"
			  $Result = 'RPC error'
			}

			"Endpoint" {
			  Write-Verbose "$(Get-Date) - Trying with Get-EventLog for systems older than Windows 2008"
			  try {
				$sysevents = Get-EventLog -ComputerName $Computer -LogName system -Newest 1000 -EntryType Error -ErrorAction Stop | `
				   ? TimeGenerated -GT $starttime | `
				   select MachineName,
				@{ Name = 'TimeCreated'; Expression = { $_.TimeGenerated } },
				@{ Name = 'ProviderName'; Expression = { $_.Source } },
				LogName,
				@{ Name = 'Id'; Expression = { $_.EventId } },
				@{ Name = 'LevelDisplayName'; Expression = { $_.EntryType } },
				Message

				if ($sysevents) {
				  $result = $sysevents
				} else {

				  Write-Warning "$(Get-Date) - No events found on $Computer"
				  $result = 'none'

				}
			  }

			  catch {
				$Result = 'error'
			  }

			}

			Default {
			  Write-Warning "$(Get-Date) - Error retrieving events from $Computer"
			}
		  }
		}
		catch [exception]{
		  Write-Warning "$(Get-Date) - No events found on $Computer"
		  $result = 'none'
		}

		if (($result -ne 'error') -and ($result -ne 'RPC error') -and ($result -ne 'none')) {
		  Write-Verbose "$(Get-Date) - Consolidating events for $Computer"
		  $lastuniqueevents = $null
		  $lastuniqueevents = @()
		  $ids = ($result | select id -Unique).id
		  foreach ($id in $ids) {
			$machineevents = $result | ? id -EQ $id
			$lastuniqueevents += $machineevents | sort timecreated -Descending | select -First 1
		  }

		  $AllResults += $lastuniqueevents

		}
		foreach ($Computer in $ComputerName) {

		  $Result = $Null
		  Write-Verbose "$(Get-Date) - Working on $Computer - Eventlog"
		  $starttime = (Get-Date).AddHours(- $HoursBack)

		  try {
			Write-Verbose "$(Get-Date) - Trying with Get-WinEvent"
			$result = Get-WinEvent -ErrorAction stop -ComputerName $Computer -filterh @{ LogName = (Get-WinEvent -ComputerName $Computer -ListLog * | ? { ($_.logtype -eq 'administrative') -and ($_.logisolation -eq 'system') } | ? recordcount).LogName; StartTime = $starttime; Level = 1,2 } | select machinename,timecreated,providername,logname,id,leveldisplayname,message
		  }

		  catch [System.Diagnostics.Eventing.Reader.EventLogException]{
			switch -regex ($_.Exception.Message) {
			  "RPC" {
				Write-Warning "$(Get-Date) - RPC error while communicating with $Computer"
				$Result = 'RPC error'
			  }

			  "Endpoint" {
				Write-Verbose "$(Get-Date) - Trying with Get-EventLog for systems older than Windows 2008"
				try {
				  $sysevents = Get-EventLog -ComputerName $Computer -LogName system -Newest 1000 -EntryType Error -ErrorAction Stop | `
					 ? TimeGenerated -GT $starttime | `
					 select MachineName,
				  @{ Name = 'TimeCreated'; Expression = { $_.TimeGenerated } },
				  @{ Name = 'ProviderName'; Expression = { $_.Source } },
				  LogName,
				  @{ Name = 'Id'; Expression = { $_.EventId } },
				  @{ Name = 'LevelDisplayName'; Expression = { $_.EntryType } },
				  Message

				  if ($sysevents) {
					$result = $sysevents
				  } else {

					Write-Warning "$(Get-Date) - No events found on $Computer"
					$result = 'none'

				  }
				}

				catch {
				  $Result = 'error'
				}

			  }

			  Default {
				Write-Warning "$(Get-Date) - Error retrieving events from $Computer"
			  }
			}
		  }
		  catch [exception]{
			Write-Warning "$(Get-Date) - No events found on $Computer"
			$result = 'none'
		  }

		  if (($result -ne 'error') -and ($result -ne 'RPC error') -and ($result -ne 'none')) {
			Write-Verbose "$(Get-Date) - Consolidating events for $Computer"
			$lastuniqueevents = $null
			$lastuniqueevents = @()
			$ids = ($result | select id -Unique).id
			foreach ($id in $ids) {
			  $machineevents = $result | ? id -EQ $id
			  $lastuniqueevents += $machineevents | sort timecreated -Descending | select -First 1
			}

			$AllResults += $lastuniqueevents

		  }
		} #
		foreach ($Computer in $ComputerName) {

		  $Result = $Null
		  Write-Verbose "$(Get-Date) - Working on $Computer - Eventlog"
		  $starttime = (Get-Date).AddHours(- $HoursBack)

		  try {
			Write-Verbose "$(Get-Date) - Trying with Get-WinEvent"
			$result = Get-WinEvent -ErrorAction stop -ComputerName $Computer -filterh @{ LogName = (Get-WinEvent -ComputerName $Computer -ListLog * | ? { ($_.logtype -eq 'administrative') -and ($_.logisolation -eq 'system') } | ? recordcount).LogName; StartTime = $starttime; Level = 1,2 } | select machinename,timecreated,providername,logname,id,leveldisplayname,message
		  }

		  catch [System.Diagnostics.Eventing.Reader.EventLogException]{
			switch -regex ($_.Exception.Message) {
			  "RPC" {
				Write-Warning "$(Get-Date) - RPC error while communicating with $Computer"
				$Result = 'RPC error'
			  }

			  "Endpoint" {
				Write-Verbose "$(Get-Date) - Trying with Get-EventLog for systems older than Windows 2008"
				try {
				  $sysevents = Get-EventLog -ComputerName $Computer -LogName system -Newest 1000 -EntryType Error -ErrorAction Stop | `
					 ? TimeGenerated -GT $starttime | `
					 select MachineName,
				  @{ Name = 'TimeCreated'; Expression = { $_.TimeGenerated } },
				  @{ Name = 'ProviderName'; Expression = { $_.Source } },
				  LogName,
				  @{ Name = 'Id'; Expression = { $_.EventId } },
				  @{ Name = 'LevelDisplayName'; Expression = { $_.EntryType } },
				  Message

				  if ($sysevents) {
					$result = $sysevents
				  } else {
					Write-Warning "$(Get-Date) - No events found on $Computer"
					$result = 'none'
				  }
				}

				catch {
				  $Result = 'error'
				}

			  }

			  Default {
				Write-Warning "$(Get-Date) - Error retrieving events from $Computer"
			  }
			}
		  }
		  catch [exception]{
			Write-Warning "$(Get-Date) - No events found on $Computer"
			$result = 'none'
		  }

		  if (($result -ne 'error') -and ($result -ne 'RPC error') -and ($result -ne 'none')) {
			Write-Verbose "$(Get-Date) - Consolidating events for $Computer"
			$lastuniqueevents = $null
			$lastuniqueevents = @()
			$ids = ($result | select id -Unique).id
			foreach ($id in $ids) {
			  $machineevents = $result | ? id -EQ $id
			  $lastuniqueevents += $machineevents | sort timecreated -Descending | select -First 1
			}

			$AllResults += $lastuniqueevents

		  }
		} #
	  }
	} #foreach($Computer in $ComputerName)
  }

  end {

	Write-Verbose "$(Get-Date) - Finished."
	$AllResults
  }
}



