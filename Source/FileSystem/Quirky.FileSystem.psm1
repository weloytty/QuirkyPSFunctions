#
# Quirky.FileSystem.psm1
#




function Set-LocationToProfileFolder ()
{remo
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
}
Set-Alias -Name slp -Value Set-LocationToProfileFolder
Set-Alias -Name home -Value Set-LocationToProfileFolder



function Set-LocationFromFile ()
{
  [CmdletBinding(SupportsShouldProcess = $true)]
  param([string]$FileOrFolderName)

  $didAnything = $false;

  if (Test-Path -Path $FileOrFolderName -PathType Container) {

    $didAnything = $true;
    Write-Verbose "Setting Location to $FileOrFolderName"

    if ($PSCmdlet.ShouldProcess("Set location to $FileOrFolderName")) {
      Set-Location -Path $FileOrFolderName
    }

  } elseif (Test-Path -Path $FileOrFolderName -PathType Leaf) {

    $didAnything = $true;
    $location = $(Split-Path -Path $FileOrFolderName -Parent)
    Write-Verbose "Setting Location to $location"

    if ($PSCmdlet.ShouldProcess("Set location to $FileOrFolderName")) {
      Set-Location $location
    }
  }

  if ($didAnything -eq $false) {
    Write-Verbose "No operation performed. $FileOrFolderName is neither a file nor a folder"
  }
}
Set-Alias -Name slf -Value Set-LocationFromFile



function Get-FileVersion () {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
    [Alias("Source","FullName")]
    [string[]]$filename)
  process
  {
    foreach ($s in $filename) {
      $ver = (Get-Item $s).VersionInfo.FileVersion
      if (Test-Path -Path $s) {
        $msg = "$s version $ver"
        if ($ver -eq $null) { $msg = "$s contains no version info" }
        Write-Output $msg
      }
    }
  }
}


function Get-FileAttributes ()
{
  [CmdletBinding()]
  param(
    [Alias("FullName")]
    [Parameter(Mandatory = $true,ValueFromPipeline = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [string[]]$Name,
    [switch]$List
  )

  if ($List)
  {
    Write-Output [enum]::GetNames ("system.io.fileattributes")
  } else {
    foreach ($file in $Name)
    {

      if (Test-Path $file)
      {
        Write-Output $(Get-Item $file -Force | select Name,Attributes)
      }
    }
  }
}

function Set-FileAttributes ()
{
  [CmdletBinding()]
  param(
    [Alias("FullName")]
    [Parameter(Mandatory = $true,ValueFromPipeline = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [string[]]$Name,
    [System.IO.FileAttributes[]]$Attribute,
    [switch]$Remove,
    [switch]$List
  )

  if ($List)
  {
    Write-Output [enum]::GetNames ("system.io.fileattributes")
  }
  else
  {
    foreach ($file in $Name)
    {
      if (Test-Path $file)
      {
        $FileAtt = Get-Item $File -Force
        foreach ($att in $Attribute)
        {
          $operation = "Adding"
          if ($Remove) { $operation = "Removing" }
          Write-Verbose "$operation Attribute: $att from $(Split-Path $file -Leaf)"
          if ($FileAtt.Attributes -band $att)
          {
            Write-Verbose "$file is $att"
            if ($Remove) {
              Write-Verbose "Turning off $att on $file"
              $fileAtt.Attributes = $($fileAtt.Attributes -bxor $att)
            }
          } else {
            Write-Verbose "$file is not $att"
            if (-not $Remove) {
              Write-Verbose "Turning on $att on $file"
              $fileAtt.Attributes = $($FileAtt.Attributes -bxor $att)
            }
          }
        }
      }
    }
  }
}

function Get-ChildItemByDate ()
{
  [CmdletBinding()]
  param(
    [string]$Path = ".",
    [bool]$Ascending = $true
  )

  Get-ChildItem -Path $Path | Sort-Object -Property @{ Expression = { $_.LastWriteTime }; Ascending = $Ascending }
}
Set-Alias -Name gcidate -Value Get-ChildItemByDate

function Get-ChildItemDirectories ()
{
  param(
    [string]$Path
  )

  if (!$Path) { $Path = "." }
  Get-ChildItem -Path $Path -Directory
}
Set-Alias -Name gcidirs -Value Get-ChildItemDirectories

function Get-ChildItemBySize () {
  param([string]$path = ".",
    [bool]$Ascending = $true
  )

  Get-ChildItem -Path $path | Sort-Object -Property @{ Expression = { $_.Length }; Ascending = $Ascending }

}
Set-Alias -Name gcisize -Value Get-ChildItemBySize -Description "$AliasDescription"





function Get-ScriptDirectory
{
  return Split-Path $script:MyInvocation.MyCommand.Path
}

function Get-LocalFileName
{
  param([string]$filename)
  return [system.io.path]::Combine((Get-ScriptDirectory),$filename)
}



