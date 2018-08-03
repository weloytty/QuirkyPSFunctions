
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
        if ($null -eq $ver ) { $msg = "$s contains no version info" }
        Write-Output $msg
      }
    }
  }

