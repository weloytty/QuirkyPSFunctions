
  (Invoke-WebRequest http://pages.cs.wisc.edu/~ballard/bofh/excuses -OutVariable excuses).content.Split([environment]::NewLine)[(Get-Random $excuses.content.Split([environment]::NewLine).Count)]

