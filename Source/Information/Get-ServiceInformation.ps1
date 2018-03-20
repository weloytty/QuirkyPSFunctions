
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
    [string[]]$ComputerName = $env:COMPUTERNAME,
    [switch]$DisplayOnly,
    [switch]$Quiet)
begin {
    Set-StrictMode -Version Latest
      

}

process {
    $returnValues = @()
    foreach ($thisServer in $ComputerName) {
        $thisSession = New-CIMSession -ComputerName $thisServer
        $serviceList = $(Get-CIMInstance -ClassName Win32_Service -CimSession $thisSession -Property Name, StartName, StartMode)|Sort-Object Name
        foreach ($thisSvc in $serviceList) {
            $thisSvcObj = New-Object -TypeName PSObject -Property @{
                ComputerName = $thisServer
                Name         = $thisSvc.Name
                StartName    = $thisSvc.StartName
                StartMode    = $thisSvc.StartMode
            }
            if (-not $DisplayOnly) {
                $returnValues += $thisSvcObj
            }
            
            if (-not $Quiet) {
                $outputString = "$($thisServer.padRight(15))$($thisSvc.Name.PadRight(35))$($thisSvc.StartName.PadRight(40))$($thisSvc.StartMode)"
                write-Host $outputString
            }
            
        }
        
        Remove-CimSession  -CimSession $thisSession
    }
    
}

end {
    if ($DisplayOnly) {$returnValues = $null}
    $returnValues
    
}