
  param(
    [string]$Path
  )

  if (!$Path) { $Path = "." }
  Get-ChildItem -Path $Path -Directory

