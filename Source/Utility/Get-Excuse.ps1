
(Invoke-WebRequest http://pages.cs.wisc.edu/~ballard/bofh/excuses).Content.Split([environment]::newline) -ne '' | Get-Random

