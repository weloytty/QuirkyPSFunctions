

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


