
  [CmdletBinding()]
  param(
  [ValidateSet('CurrentUserCurrentHost','CurrentUserAllHosts','AllUsersCurrentHost','AllUsersAllHosts')]
  [Parameter(Position=0)]
  [string]$ProfileToUse = "CurrentUserCurrentHost"
  )

  Set-StrictMode -Version Latest

  $profileFile = ''
    
  if($ProfileToUse -eq 'CurrentUserCurrentHost'){$profileFile = $Profile.CurrentUserCurrentHost}
  if($profileFile -ne '') {Write-Verbose "profile.CurrentUserCurrentHost is $($profile.CurrentUserCurrentHost)"}

  if($profileFile -eq '' -or $ProfileToUse -eq 'CurrentUserAllHosts') {$profileFile = $profile.CurrentUserAllHosts}
  if($profileFile -ne '' -or $ProfileToUse -eq 'CurrentUserAllHosts') {Write-Verbose "profile.CurrentUserAllHosts is $($profile.CurrentUserAllHosts)"}

  if($profileFile -eq '' -or $ProfileToUse -eq 'AllUsersCurrentHost') {$profileFile = $profile.AllUsersCurrentHost}
  if($profileFile -ne '') {Write-Verbose "profile.AllUsersCurrentHost is $($profile.AllUsersCurrentHost)"}

  if($profileFile -eq '' -or $ProfileToUse -eq 'AllUsersAllHosts') {$profileFile = $profile.AllUsersAllHosts}
  if($profileFile -ne '' ) {Write-Verbose "profile.AllUsersAllHosts is $($profile.AllUsersAllHosts)"}
  

  Write-Verbose "Profile requested is `'$ProfileToUse`'"
  Write-Verbose "Profile used is `'$profileFile`'"
  
  $ProfileLocation = Split-Path -Parent -Path $ProfileFile
  Set-Location $ProfileLocation

