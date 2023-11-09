
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
  [Alias("Source", "FullName")]
  [string[]]$filename,
  [switch]$Quiet,
  [switch]$DisplayOnly)
process {
  $returnValues = @()
  foreach ($s in $filename) {
    if (Test-Path -Path $s) {

      $fileItem = Get-Item $s
      $ver = $fileItem.VersionInfo.FileVersion
      $msg = "$($s.padRight(70))$ver"
      if ($null -eq $ver ) { $msg = "$s contains no version info" }
      if (-not $Quiet) { Write-Output "$msg" }
        
      [hashtable]$returnItem = @{}
      $returnItem.Name = $fileItem.Name
      $returnItem.FileFullName = $fileItem.FullName
      $returnItem.Directory = $fileItem.DirectoryName
      $returnItem.Version = $ver
        
      $returnObject = New-Object psobject -Property $returnItem
      $returnValues += $returnObject

    }
  }
  $returnValues
}

