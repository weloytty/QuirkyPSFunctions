[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string[]]$ComputerName,
    [switch]$Quiet,
    [switch]$DisplayOnly
)
    
begin {
    Set-StrictMode -Version Latest

}
    
process {
    $returnValues = @()
    foreach ($Computer in $ComputerName) {
        $PaddedComputer = $Computer.PadRight(15)
        
        $pfToCheck = "\\$computer\c$\pagefile.sys"
       
       
        If (Test-NetConnection -ComputerName $Computer -InformationLevel Quiet -CommonTCPPort SMB) {
            $computerValue = @{}
            $computerValue.ComputerName = $Computer
            if (Test-Path -Path $pfToCheck ) {
                $pfSize = $(Get-ChildItem -Path $pfToCheck  -Hidden|Select-Object -expand Length)
                $formatSize = $(Format-DiskSize $pfSize)
                $computerValue.PageFileLength = $pfSize
                if (-not $DisplayOnly) {$returnValues += $ComputerValue}
                if (-not $Quiet) {Write-Host $paddedComputer $formatSize} 
            } else {
                if (-not $Quiet) {Write-Host "$PaddedComputer :CAN'T READ (PERMISSIONS?)"}
            }
            
        } else {if (-not $Quiet) {Write-Host "$PaddedComputer :MISSING"}}
    }



}
    
end {
    $returnValues
}

