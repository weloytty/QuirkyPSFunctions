
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

