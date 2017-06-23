
  Stop-Process -Id (Get-Process PowerShell | Where-Object { $_.Id -ne $Pid }).Id -Force

