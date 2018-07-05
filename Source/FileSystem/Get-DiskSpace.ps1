[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string[]]$ComputerName = $null,
    [string]$Drive,
    [switch]$Quiet,
    [switch]$DisplayOnly,
    [switch]$IncludeZeros)

begin {
    Set-StrictMode -Version Latest




    $returnValues = @()


    $wmiQuery = "select * from Win32_LogicalDisk"
    if ($Drive -ne "") {
        $wmiQuery += " where Name='$($Drive.Trim())'"
    }

    if ($null -eq $ComputerName ) {
        $ComputerName = "$Env:COMPUTERNAME"
        
    }
}

process {

    foreach ($Computer in $ComputerName) {
        Write-Verbose "Processing $Computer"
        
        $driveInfo = $(Get-CimInstance -ComputerName $Computer -Query $wmiQuery)
        if ($null -ne $driveInfo) {
            
            foreach ($results in $driveInfo) {
                if ($null -ne $results) {
                    $resSize = $results.Size
                    $resFree = $results.FreeSpace


                    if ($null -eq $results.Size) {$resSize = 0}
                    if ($null -eq $results.FreeSpace) {$resFree = 0}
                    $percentFree = 0


                    
                    if (  $resSize -ne 0) {
                        $percentFree = [int](100 - (((($resSize) - ($resFree)) / ($resSize) * 100)))                        
                    }


                    if (-not $DisplayOnly) {
                        $thisValue = $(New-Object -Type PSObject -Property @{ ComputerName = $Computer; Disk = $($results.DeviceId); Size = $($results.Size); FreeSpace = $($results.FreeSpace); PercentFree = $percentFree })
                        $returnValues += $thisValue    
                    }
                    if (-not $Quiet) {

                    

                        if ($results.Size -gt 0 -or $IncludeZeros) {
                            $compDisplay = "$($Computer.PadRight(15))    "
                            $foreColor = 'Green'
                            if ($percentFree -lt 10) {$foreColor = 'Red'}
                  
                            $outputStringFreeSpace = "Free: $($(Format-DiskSize -Size $results.FreeSpace).padRight(10))" 
                            $outputStringSize = "Size: $($(Format-DiskSize -Size $results.Size).padRight(10))"
                            $driveName = $($results.Name)
                            Write-Host "$compDisplay$driveName $outputStringSize$outputStringFreeSpace% Free: " -NoNewLine 
                            Write-Host "$percentFree" -ForegroundColor $foreColor
                        }
                    }
                }#if($null -ne $results){
            }#foreach ($results in $driveInfo) {
        }    
        if (-not $Quiet) {Write-Host ""}
    }

}

end {
    if ($DisplayOnly) {$returnValues = $null}
    $returnValues
}