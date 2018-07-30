
  [CmdletBinding()]
  param(
    [Alias("FQDN")]
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName = $true,Position = 0)]
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

      if ((Get-CimInstance -ClassName win32_operatingsystem).OSArchitecture -notlike '64-bit') {
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
    Write-Verbose "Appresults is null: $($null -eq $Appresults)"
    Write-Verbose "Publisher Results is null: $($null -eq $publisherResults)"
    if (($AppName -ne "") -or ($Publisher -ne "")) {
      $results = $publisherResults + $appResultsResults
    }


	return $results

  }
