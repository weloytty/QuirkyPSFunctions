
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

