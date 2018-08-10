
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
    [Alias("Source","FullName")]
    [string[]]$filename)
  process
  {
    foreach ($s in $filename) {
      if (Test-Path -Path $s) {
        $ver = (Get-Item $s).VersionInfo.FileVersion
        $msg = "$s version $ver"
        if ($null -eq $ver ) { $msg = "$s contains no version info" }
        Write-Output $msg
      }
    }
  }

