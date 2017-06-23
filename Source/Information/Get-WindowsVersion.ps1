
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

