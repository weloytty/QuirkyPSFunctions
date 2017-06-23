
  [CmdletBinding()]
  param(
    [string]$Path = ".",
    [bool]$Ascending = $true
  )

  Get-ChildItem -Path $Path | Sort-Object -Property @{ Expression = { $_.LastWriteTime }; Ascending = $Ascending }

