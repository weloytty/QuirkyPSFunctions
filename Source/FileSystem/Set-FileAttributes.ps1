
[CmdletBinding()]
param(
  [Alias("FullName")]
  [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
  [string[]]$Name,
  [System.IO.FileAttributes[]]$Attribute,
  [switch]$Remove,
  [switch]$List
)

if ($List) {
  Write-Output [enum]::GetNames ("system.io.fileattributes")
} else {
  foreach ($file in $Name) {
    if (Test-Path $file) {
      $FileAtt = Get-Item $File -Force
      foreach ($att in $Attribute) {
        $operation = "Adding"
        if ($Remove) { $operation = "Removing" }
        Write-Verbose "$operation Attribute: $att from $(Split-Path $file -Leaf)"
        if ($FileAtt.Attributes -band $att) {
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

