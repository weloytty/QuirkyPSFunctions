
  [CmdletBinding()]
  param(
    [Alias("FQDN")]
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

