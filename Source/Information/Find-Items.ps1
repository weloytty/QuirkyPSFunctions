
  param([string]$filePath = ".",
	[string]$fileName = "*")

  Get-ChildItem -Recurse -Force $filePath -ErrorAction SilentlyContinue | `
	 Where-Object { ($_.PSisContainer -eq $false) -and ($_.Name -like "*$fileName*") } | `
	 Select-Object Name,Directory | Format-Table -AutoSize *


