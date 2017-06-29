[CmdletBinding()]
  param(
    [Parameter(ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
    [string[]]$computername = $env:COMPUTERNAME,
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty)
  process {
    Write-Verbose "Processing $computername"
    foreach ($s in $computername) {

      Get-WmiObject win32_share -ComputerName $s | Format-Table Name,Path -AutoSize
    }
  }
