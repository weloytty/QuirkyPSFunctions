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

    function Format-DiskSize {
        param ($Size)
        switch ($Size) {
            {$_ -ge 1PB} {"{0:0000.##' P'}" -f ($size / 1PB); break}
            {$_ -ge 1TB} {"{0:0000.##' T'}" -f ($size / 1TB); break}
            {$_ -ge 1GB} {"{0:0000.##' G'}" -f ($size / 1GB); break}
            {$_ -ge 1MB} {"{0:0000.##' M'}" -f ($size / 1MB); break}
            {$_ -ge 1KB} {"{0:0000.##' K'}" -f ($size / 1KB); break}
            default {"{0:0000.##}" -f ($Size) + " B"}
        }
    }


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
        
        $driveInfo = $(Get-WmiObject -ComputerName $Computer -Query $wmiQuery)
        if ($null -ne $driveInfo) {
            
            foreach ($results in $driveInfo) {
                if ($null -eq $results.Size) {$results.Size = 0}
                if ($null -eq $results.FreeSpace) {$results.FreeSpace = 0}
                $percentFree = 0


                    
                if (  $results.Size -ne 0) {
                    $percentFree = [int](100 - (((($results.Size) - ($results.FreeSpace)) / ($results.Size) * 100)))                        
                }


                if (-not $DisplayOnly) {
                    $thisValue = $(New-Object -Type PSObject -Property @{ ComputerName = $Computer; Disk = $($results.DeviceId); Size = $($results.Size); FreeSpace = $($results.FreeSpace); PercentFree = $percentFree })
                    $returnValues += $thisValue    
                }
                if (-not $Quiet) {

                    

                    if ($results.Size -gt 0 -or $IncludeZeros) {
						$compDisplay = $Computer.PadRight(15)
                        $foreColor = 'Green'
                        if ($percentFree -lt 10) {$foreColor = 'Red'}
                  
                        $outputStringFreeSpace = "Free: $($(Format-DiskSize -Size $results.FreeSpace).padRight(10))" 
                        $outputStringSize = "Size: $($(Format-DiskSize -Size $results.Size).padRight(10))"
                        $driveName = $($results.Name).padRight(10)
                        Write-Host "$compDisplay$driveName$outputStringSize$outputStringFreeSpace% Free: " -NoNewLine 
                        Write-Host "$percentFree" -ForegroundColor $foreColor
                    }
                }
            }
        }    
        if (-not $Quiet) {Write-Host ""}
    }

}

end {
    if ($DisplayOnly) {$returnValues = $null}
    $returnValues
}