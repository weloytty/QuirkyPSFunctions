
  param([string]$path = ".",
    [bool]$Ascending = $true
  )

  Get-ChildItem -Path $path | Sort-Object -Property @{ Expression = { $_.Length }; Ascending = $Ascending }


