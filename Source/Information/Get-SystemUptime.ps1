
[CmdletBinding()]
param(
    [Alias("FQDN")]
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string[]]$ComputerName = $(hostname),
    [switch]$DisplayOnly,
    [switch]$Quiet)


begin {
    $returnValues = @()

    if ($Quiet -and $DisplayOnly) {
        Write-Verbose "Quiet and DisplayOnly were both set, no output will be produced"
    }
}

process {
    foreach ($computer in $ComputerName) {
        if (Test-NetConnection -InformationLevel Quiet -ComputerName $computer -CommonTCPPort WinRM) {
            #$operatingSystem = Get-WmiObject Win32_OperatingSystem -ComputerName $computer;
            $operatingSystem = Get-CIMInstance -ClassName Win32_OperatingSystem -ComputerName $computer;
            #"$((Get-Date) - ([Management.ManagementDateTimeConverter]::ToDateTime($operatingSystem.LastBootUpTime)))";


            #$LastBootUpTime = $([Management.ManagementDateTimeConverter]::ToDateTime($operatingSystem.LastBootUpTime))
            $LastBootUpTime = $operatingSystem.LastBootUpTime
            $timeDiff = New-TimeSpan $LastBootUpTime $(Get-Date)
            $differenceOutput = '{0:00} Days {1:00} hours {2:00} minutes {3:00} seconds' -f $timeDiff.Days, $timeDiff.Hours, $timeDiff.Minutes, $timeDiff.Seconds
            if (-not $Quiet) {
                Write-Host "$($computer.padRight(15)) $differenceOutput"
            }

            if (-not $DisplayOnly) {
                $thisValue = $(New-Object -Type PSObject -Property @{ ComputerName = $computer; TimeSpanSinceBoot = $timeDiff })
                $returnValues += $thisValue
            }


        } else { Write-Verbose "Can't connect to $computer" }
    }
}

end {
    return $returnValues
}




