param([string]$filePath = ".",
    [string]$fileName = "*")

Get-ChildItem -Recurse -Force $filePath -ErrorAction SilentlyContinue | `
    Where-Object { ($_.PSIsContainer -eq $false) -and ($_.Name -like "$fileNam*") } | `
    Select-Object Name, Directory | Format-Table -AutoSize *
