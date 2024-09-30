
[CmdletBinding(SupportsShouldProcess = $true)]
param([string]$FileOrFolderName)

$didAnything = $false;

if (Test-Path -Path $FileOrFolderName -PathType Container) {

  $didAnything = $true;
  Write-Verbose "Setting Location to $FileOrFolderName"

  if ($PSCmdlet.ShouldProcess("Set location to $FileOrFolderName")) {
    Set-Location -Path $FileOrFolderName
  }

}
elseif (Test-Path -Path $FileOrFolderName -PathType Leaf) {

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

