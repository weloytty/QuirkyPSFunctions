
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

