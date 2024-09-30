
[CmdletBinding()]
param()

if ($IsWindows) { return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator') }
if ($IsLinux) {
  $uid = [System.Diagnostics.Process]::GetCurrentProcess().StartInfo.EnvironmentVariables['UID']
  return $uid -eq '0'
}

throw 'Unsupported platform'


  


