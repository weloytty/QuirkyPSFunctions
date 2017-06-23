
# PersonalFunctions.psm1
#

filter isNumeric () {
  return $_ -is [byte] -or $_ -is [int16] -or $_ -is [int32] -or $_ -is [int64] `
	 -or $_ -is [sbyte] -or $_ -is [uint16] -or $_ -is [uint32] -or $_ -is [uint64] `
	 -or $_ -is [float] -or $_ -is [double] -or $_ -is [decimal]
}



function Get-MD5Checksum ()
{
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true,Mandatory = $true,ParameterSetName = "Files")]
	[string[]]$FileName,
	[Parameter(ValueFromPipeline = $true,Mandatory = $true,ParameterSetName = "String")]
	[string[]]$String,
	[string]$Encoding = "UTF-8"
  )

  begin
  {
	$returnArray = @()
	$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
  }

  process
  {


	foreach ($file in $fileName)
	{
	  if (Test-Path $file -PathType Leaf)
	  {

		$filePath = Get-Item $file | select -ExpandProperty FullName

		[byte[]]$hashBytes = $md5.ComputeHash([System.IO.File]::ReadAllBytes($filePath))


		$hash = [System.BitConverter]::ToString($hashBytes)
		$returnValues = @{}
		$returnValues.FileName = $filePath
		$returnValues.HashBytes = $hashBytes
		$returnValues.HashString = $hash
		$returnValues.HashBase64String = [System.Convert]::ToBase64String($hashBytes)
		$returnArray += $(New-Object -Type PSObject -Property $returnValues)


	  }
	}

	foreach ($thisString in $string)
	{
	  $encoder = $null
	  switch ($encoding)
	  {
		"UTF-8" { $encoder = [System.Text.Encoding]::UTF8 }
		"UTF-16" { $encoder = [System.Text.Encoding]::UTF16 }
		"ASCII" { $encoder = [System.Text.Encoding]::ASCII }
		"UNICODE" { $encoder = [System.Text.Encoding]::UNICODE }
	  }


	  #[byte[]]$hash = [System.BitConverter]::ToString($md5.ComputeHash($encoder.GetBytes($thisString)))
	  [byte[]]$hashBytes = $md5.ComputeHash($encoder.GetBytes($thisString))
	  $hash = [System.BitConverter]::ToString($hashBytes)
	  $returnValues = @{}
	  $returnValues.String = $thisString
	  $returnValues.HashBytes = $hashBytes
	  $returnValues.HashString = $hash
	  $returnValues.HashBase64String = [System.Convert]::ToBase64String($hashBytes)
	  $returnArray += $(New-Object -Type PSObject -Property $returnValues)
	}

  }

  end
  {
	return $returnArray
  }
}
Set-Alias md5 -Value Get-MD5Checksum


function Find-Items {
  param([string]$filePath = ".",
	[string]$fileName = "*")

  Get-ChildItem -Recurse -Force $filePath -ErrorAction SilentlyContinue | `
	 Where-Object { ($_.PSisContainer -eq $false) -and ($_.Name -like "*$fileName*") } | `
	 Select-Object Name,Directory | Format-Table -AutoSize *

}
Set-Alias fi -Value Find-Items

function Get-VmIp()
{
	[CmdLetBinding()]
	param([string[]] $VMName)

	begin
	{}

	process 
	{
		foreach($vm in $VMName)
		{
			Get-VMNetworkAdapter -VMName $vm|Select-Object IpAddresses|Foreach-Object {$_.IpAddresses}
		}
	}

	end
	{}

}



function Test-Win32 ()
{
  return [intptr]::Size -eq 4
}

function Test-Win64 ()
{
  return [intptr]::Size -eq 8
}


function Set-EnvironmentVariable ()
{
  [CmdletBinding()]
  param(
	[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true)]
	[string]$VariableName,
	[ValidateSet('User','Machine')]
	[string]$Scope = 'User'
  )

  process {
	$returnValue = ""
	if ($VariableName.Contains('%'))
	{
	  $returnValue = [string][System.Environment]::ExpandEnvironmentVariables($VariableName)
	} else {
	  $returnValue = [environment]::SetEnvironmentVariable($VariableName,$Scope)

	}
	return Get-EnvironmentVariable $VariableName $Scope
  }
}
Set-Alias sev Set-EnvironmentVariable


function Get-EnvironmentVariable ()
{
  [CmdletBinding()]
  param(
	[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true)]
	[string]$VariableName,
	[ValidateSet('User','Machine')]
	[string]$Scope = 'User'
  )

  process {
	$returnValue = ""
	if ($VariableName.Contains('%'))
	{
	  $returnValue = [string][System.Environment]::ExpandEnvironmentVariables($VariableName)
	} else {
	  $returnValue = [environment]::GetEnvironmentVariable($VariableName,$Scope)

	}
	return $returnValue
  }
}
Set-Alias gev Get-EnvironmentVariable



function Set-IEFriendlyErrors () {
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
}
Set-Alias ief -Value Set-IEFriendlyErrors

function Set-IESecureProtocols () {
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
}
Set-Alias iesp -Value Set-IESecureProtocols




function Get-NumberOfDays ()
{
  [CmdletBinding()]
  param(
	[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true)]
	[string]$FirstDate,
	[Parameter(Mandatory = $true,Position = 1,ValueFromPipeline = $true)]
	[string]$SecondDate
  )

  $FromDate = $FirstDate -as [datetime]
  $ToDate = $SecondDate -as [datetime]

  if (!$FromDate) { (throw "$FirstDate is not a valid date.") }
  if (!$ToDate) { (throw "$SecondDate is not a valid date.") }
  $numdays = (New-TimeSpan -Start $FromDate -End $ToDate).Days.ToString()
  $days = "days"

  if ($numdays -eq 0) { $days = "day" }
  Write-Verbose "$numdays $days between $($FromDate.ToShortDateString()) and $($ToDate.ToShortDateString())"

  [hashtable]$returnValues = @{}
  $returnValues.FromDate = $FromDate
  $returnValues.ToDate = $ToDate
  $returnValues.NumberOfDays = $numdays

  $returnObject = New-Object psobject -Property $returnValues

  return $returnObject
}

function Get-DaysUntilChristmas ()
{
  [CmdletBinding()]
  param(
	[string]$date = ($(Get-Date -Format "d").ToString()),
	[string]$whatyear = ($(Get-Date).Year)
  )

  #$fromDate = [datetime]::ParseExact($date,"d",$null)

  $fromDate = $date -as [datetime];
  if (!$fromDate) {
	throw "$date is not a valid date"
  }


  if ((($fromDate).Month -eq 12) -and (($fromDate).Day -gt 24)) { $whatYear = $whatYear + 1 }

  $EndDate = (Get-Date 12/25/$whatYear)

  $numdays = (New-TimeSpan -Start ($fromDate) -End $EndDate).Days.ToString()
  $days = "days"
  if ($numdays -eq 1) { $days = "day" }

  Write-Verbose "There are $numdays $days from $(($fromDate).ToShortDateString()) until Christmas $whatyear "
  [hashtable]$returnValues = @{}
  $returnValues.FromDate = $FromDate
  $returnValues.ToDate = $EndDate
  $returnValues.NumberOfDays = $numdays

  $returnObject = New-Object psobject -Property $returnValues

  return $returnObject
}
Set-Alias howlonguntilchristmas Get-DaysUntilChristmas

function Stop-OtherPowershell ()
{
  Stop-Process -Id (Get-Process PowerShell | Where-Object { $_.Id -ne $Pid }).Id -Force
}
Set-Alias killps Stop-OtherPowershell

function Get-Excuse {
  (Invoke-WebRequest http://pages.cs.wisc.edu/~ballard/bofh/excuses -OutVariable excuses).content.Split([environment]::NewLine)[(Get-Random $excuses.content.Split([environment]::NewLine).Count)]
}

function Get-ExpandedURL {
  [CmdletBinding()]
  param(
	[Parameter(Mandatory = $true,ValueFromPipeline = $true,Position = 0)]
	[string[]]$inputURLs,
	[switch]$NavigateToURL,
	[switch]$ShowIntermediateURLs)
  begin {
	Add-Type -AssemblyName System.Web
  }
  process {
	foreach ($inputURL in $InputURLs) {
	  $escapedURL = [System.Web.HttpUtility]::UrlEncode($inputURL)
	  $a = (Invoke-RestMethod https://lengthenurl.info/api/longurl/shorturl/?inputURL=$escapedURL)
	  Write-Output $a.LongURL

	  if ($ShowIntermediateURLs)
	  {
		Write-Output ""
		Write-Output "Intermediate URLS"
		foreach ($s in $a.IntermediateURLs)
		{
		  Write-Output "     $s"
		}
		Write-Output ""
	  }
	  if ($NavigateToURL)
	  { Start-Process $a.LongURL }
	  else
	  {
		#PSCX has a better Set-Clipboard, but I don't want a dependency
		Microsoft.PowerShell.Management\Set-Clipboard $a.LongURL
	  }


	}
  }

}
Set-Alias gurl Get-ExpandedURL

function Edit-File ()
{
  [CmdletBinding()]
  param(
	[Alias("Path")]
	[Parameter(Mandatory = $true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string]$FileName,
	[switch]$NoArguments
  )


  $command = $Global:QuirkyPreferences.Get_Item("EditorCommand")
  $arguments = $Global:QuirkyPreferences.Get_Item("EditorArguments")
  if ($arguments -eq $null) { $arguments = '' }
  Write-Verbose "Preferences editor is '$command'"
  Write-Verbose "Preferences arguments is '$arguments'"

  $expandedCommand = (Get-Command "notepad.exe").Source
  if ($command -eq $null) {
	$command = "notepad.exe"
	$arguments = ''
  }

  if (Get-Command "$command")
  {

	$expandedCommand = (Get-Command $command).Source
	Write-Verbose "$command expands to $expandedCommand"
  }

  if (Test-Path $fileName -PathType Leaf)
  {
	Write-Verbose "Expanding $fileName"
	$fileName = $(Get-Item $fileName | select -ExpandProperty FullName)
	Write-Verbose "File name is now $fileName"
  }


  $pushed = $false
  #if it starts with "Microsoft.PowerShell.Core\FileSystem::", it's a network path
  if ((Get-Location).Path.StartsWith("Microsoft.PowerShell.Core\FileSystem::"))
  {
	$pushed = $true
	Push-Location
	Write-Verbose "Setting Location to $expandedCommand"
	Set-Location $(Split-Path "$expandedCommand")

  }



  #Write-Verbose "Running `"$expandedCommand`" `"$fileName`" $($argments.Split(','))"

  & "$expandedCommand" "$fileName" $arguments.Split(',')

  if ($pushed)
  { Pop-Location }



}

function Update-SysInternals ()
{

  [CmdletBinding()]
  param([string]$DownloadLocation = $env:temp,
	[string]$ExtractLocation = '',
	[switch]$CopyOnly,
	[switch]$Force,
	[switch]$NoDelete
  )

  Set-StrictMode -Version Latest

  if ($ExtractLocation -eq '')
  {
	Write-Verbose "Sysinternals Directory will be $($Global:QuirkyPreferences.Get_Item("SysinternalsDir"))"
	$extractLocation = $Global:QuirkyPreferences.Get_Item("SysinternalsDir")
	if ($ExtractLocation -eq $null -or $ExtractLocation -eq "")
	{
	  $ExtractLocation = Join-Path $("$Env:localappdata\programs") "SysInternals"
	}
  }

  Write-Output ""
  Write-Output "Get-LatestSysinternals: Downloads and expands SysinternalsSuite.zip to your computer"
  Write-Output "Unless specified in Quirky.Preferences, the file will be extracted into"
  Write-Output "$ENV:LOCALAPPDATA\Programs."
  Write-Output "Current session will use $ExtractLocation"
  Write-Output ""



  $sourceFile = $null

  $targetFile = "SysinternalsSuite.zip"
  $baseUrl = 'https://download.sysinternals.com/files/'
  $urlToGet = "$baseUrl$targetFile"


  if (-not (Test-Path -Path $DownloadLocation -PathType Container)) { throw "Bad DownloadLocation $DownloadLocation" }
  if (-not (Test-Path -Path $ExtractLocation -PathType Container))
  {
	Write-Output "Creating $ExtractLocation"
	New-Item -Path $ExtractLocation -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
	if (-not (Test-Path -Path $ExtractLocation)) { throw "Could not create $extractLocation" }
  }

  $downloadFile = (Join-Path $DownloadLocation $targetFile)
  $NewFileChecksum = Get-MD5Checksum -String "$DownloadLocation"
  $CurrentFileChecksum = Get-MD5Checksum -String "$ExtractLocation"

  $fileToExtract = $(Join-Path $ExtractLocation $targetFile)
  Write-Verbose "URL              : $urlToGet"
  Write-Verbose "Download File    : $downloadFile"
  Write-Verbose "Saved File       : $fileToExtract"

  if (Test-Path $fileToExtract)
  {
	$CurrentFileChecksum = (Get-MD5Checksum -FileName $fileToExtract)

  }

  Write-Output "Downloading"
  Write-Output "       $urlToGet "
  Write-Output "       to $downloadFile"
  Invoke-WebRequest -Uri $urlToGet -OutFile $downloadFile

  if (-not (Test-Path $downloadFile)) { throw "Can't find downloaded file $downloadFile" }

  $NewFileChecksum = (Get-MD5Checksum -FileName $downloadFile)
  Write-Verbose "New File MD5    : $($NewFileChecksum.HashString)"
  Write-Verbose "Old File MD5    : $($CurrentFileChecksum.HashString)"


  if ($Force) { Write-Output "Force is set, file will be copied to $fileToExtract" }

  if ($Force -or ($CurrentFileChecksum.HashString -ne $NewFileChecksum.HashString))
  {
	Write-Verbose "Copying:"
	Write-Verbose "$downloadFile"
	Write-Verbose "to $fileToExtract"
	if ($downloadFile -ne $fileToExtract)
	{
	  Write-Output "Copying archive to $fileToExtract"
	  Copy-Item $downloadFile $fileToExtract -Force
	}

	if (-not $CopyOnly)
	{
	  if ($PSVersionTable.PSVersion.Major -ge 5) {
		Write-Output "Expanding Archive"
		Microsoft.PowerShell.Archive\Expand-Archive -Path $fileToExtract -DestinationPath $ExtractLocation -Force -Verbose:$VerbosePreference
	  } else { Write-Warning "ExpandArchive can only be used on PS 5+" }

	}
  } else {
	Write-Output "Not extracting file, files match."
	Write-Verbose "     New File MD5    : $($Newfilechecksum.HashString)"
	Write-Verbose "     Current File MD5: $($CurrentFileChecksum.HashString)"
	Write-Verbose "     To force extraction, run the command again with -Force"
  }

  if ((-not $NoDelete) -and (Test-Path -Path $downloadFile))
  {
	Write-Output "Deleting $downloadFile"
	Remove-Item $downloadFile -Force
  }

}


function ConvertTo-UTF8 ()
{
[CmdLetBinding()]
param(
	[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string[]]$FileName
)

begin
{
	Set-StrictMode -Version Latest
}

process
{
	foreach($file in $FileName)
	{
		$thisItem = Get-Item $File
		$a = Get-Content $($thisItem.FullName) -Enc Unicode
		Set-Content -Encoding UTF8 $($thisItem.FullName) -value $a
	}

}}


function Add-TrustedHost ()
{
  [CmdletBinding()]
  param([string[]]$ComputerName,
	[switch]$ViewOnly,
	[switch]$OverWriteAll,
	[switch]$Force)

  begin
  {
	Set-StrictMode -Version Latest
  }
  process
  {

	if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
	{
	  if (Test-Path wsman::localhost\client\trustedhosts)
	  {
		$currentValue = (Get-Item -Path wsman::localhost\client\TrustedHosts).Value

		Write-Verbose "Current Value is $currentValue"

		if ($OverWriteAll) { $currentValue = $null }

		$newItems = @()

		if ($currentValue -ne $null -and $currentValue.Length -gt 0)
		{
		  $currentItemsMessage = "Current Trusted Hosts:"
		  if ($VerbosePreference -and (-not $ViewOnly))
		  {
			Write-Verbose $currentItemsMessage
		  } else
		  {
			Write-Output $currentItemsMessage
		  }
		  foreach ($s in $currentValue.Split(','))
		  {
			if (($s.Length -gt 0) -and (-not $newItems.Contains($s))) { $newItems += $s }
			$WhatToWrite = $s
			if ($VerbosePreference -and (-not $ViewOnly))
			{
			  Write-Verbose $s
			} else {
			  Write-Output $s
			}
		  }
		}
		if (-not $ViewOnly)
		{
		  foreach ($item in $ComputerName)
		  {
			if (-not $newItems.Contains($item))
			{
			  $newItems += $item
			}
		  }

		  if ($newItems.Length -gt 0)
		  {

			Write-Verbose "Old Value: $currentValue"
			if ($newItems.Length -gt 1)
			{ [string]$newString = [string]::Join(",",$newItems) } else { $newString = $newItems }

			Write-Verbose "New Value: $newString"
			if ($ComputerName.Contains('*') -or $newItems.Contains('*')) { $newString = '*' }
			if ($Force -or (-not $ViewOnly -and ($newString -ne $currentValue)))
			{
			  Write-Verbose "Set-Item wsman::localhost\client\trustedhosts -value $newString -Force"
			  Set-Item wsman::localhost\client\trustedhosts -Value $newString -Force
			}
		  }
		}
	  }
	} else { Write-Error "No admin rights. Run elevated." }

  }

}



function Get-TrustedHost ()
{
  [CmdletBinding()]
  param([string[]]$ComputerName = 'localhost',
	[switch]$ViewOnly,
	[switch]$OverWriteAll,
	[switch]$Force)

  begin
  {
	Set-StrictMode -Version Latest
  }
  process
  {

	if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
	{
	  foreach ($Computer in $ComputerName)
	  {
		if (Test-Path wsman::$Computer\client\trustedhosts)
		{
		  $currentValue = (Get-Item -Path wsman::localhost\client\TrustedHosts).Value

		  Write-Output "Current Value is $currentValue"
		}

	  }


	} else { Write-Error "No admin rights. Run elevated." }

  }

}




function Format-Environment
{
  [CmdletBinding()]
  param(
	[Parameter(Mandatory = $true,ValueFromPipeline = $true)]
	[string]$EnvironmentPath
  )
  process {
	$a = Get-ChildItem env:$EnvironmentPath

	foreach ($s in $a.Value.Split(";")) { $s }
  }
}
Set-Alias fev -Value Format-Environment




function Format-QXml ()
{
[CmdletBinding()]
param([string[]]$FileName)

	begin
	{
		Set-StrictMode -Version Latest
	}
	process
	{
		foreach($file in $FileName)
		{

			[xml]$xml = Get-Content $file
			$StringWriter = New-Object System.IO.StringWriter
			$XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter
			$xmlWriter.Formatting = [System.Xml.Formatting]::Indented
			$xmlWriter.Indentation = $Indent
			$xml.WriteContentTo($XmlWriter)
			$XmlWriter.Flush()
			$StringWriter.Flush()
			Write-Output $StringWriter.ToString()
		}
	}


}
Set-Alias ppx -Value Format-QXml

function Test-Transcribing {
	$externalHost = $host.gettype().getproperty("ExternalHost",
		[reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())

	try {
		$externalHost.gettype().getproperty("IsTranscribing",
		[reflection.bindingflags]"NonPublic,Instance").getvalue($externalHost, @())
	} catch {
			 write-warning "This host does not support transcription."
		 }
}