
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [string[]]$ComputerName = $($env:computername),
    [switch]$DisplayOnly,
    [switch]$Quiet)
begin {
    $SB = {param(
            $Verbose,
            $Quiet,
            $DisplayOnly)
        
        $paddedComputer = $env:ComputerName.padRight(15)
        $VerbosePreference = $Verbose
        $ComponentBasedServicing = $false
        $cbsValue = (Get-ChildItem 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\').Name
        if ($cbsValue -ne $null) {
            $ComponentBasedServicing = $cbsValue.Split("\") -contains "RebootPending"
        }

        Write-Verbose "ComponentBasedServicing is $ComponentBasedServicing"

        $WindowsUpdate = $false
        $wuValue = (Get-ChildItem 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\').Name
        if ($wuValue -ne $null) {
            $WindowsUpdate = $wuValue.Split("\") -contains "RebootRequired"
        }

        Write-Verbose "WindowsUpdate is $WindowsUpdate"

        $renameOps = $(Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\').PendingFileRenameOperations

        $PendingFileRename = ($renameOps.Length -gt 0)
        Write-Verbose "PendingFileRename is $PendingFileRename"
        if ($VerbosePreference -and $PendingFileRename) {
            Write-Verbose ""
            Write-Verbose "Pending File Rename Operations"
            for ($i = 0; $i -lt $renameOps.Length; $i++) {
                if ($renameOps[$i].Length -gt 0) {
                    Write-Verbose $renameOps[$i]
                }
            }
            Write-Verbose ""
        }
        $ActiveComputerName = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName').ComputerName
        Write-Verbose "ActiveComputerName is $ActiveComputerName"
        $PendingComputerName = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName').ComputerName
        Write-Verbose "PendingComputerName is $PendingComputerName"
        $PendingComputerRename = $ActiveComputerName -ne $PendingComputerName
        Write-Verbose "PendingComputerRename is $PendingComputerRename"

        $reason = "Cause:"

        if ($ComponentBasedServicing) {
            $reason = "$reason [ComponentServicing] "
        }
        if ($WindowsUpdate) {
            $reason = "$reason [WindowsUpdate] "
        }
        if ($PendingFileRename) {
            $reason = "$reason [File Rename] "
        }
        if ($PendingComputerRename) {
            $reason = "$reason [Computer Rename]"
        }

        $needsReboot = ($ComponentBasedServicing -or $WindowsUpdate -or $PendingFileRename -or $PendingComputerRename)

        if (-not $needsReboot) {
            $reason = ""
        }
        if (-not $Quiet) {
            Write-Output "$PaddedComputer needs reboot: $needsReboot $reason"
        }
        if ($DisplayOnly) {
            $needsReboot = $null
        }
        return $needsReboot

    }

}

process {

    foreach ($Computer in $ComputerName) {
        if (Test-Port -ComputerName $computer -Quiet -Port 3389) {
            if ($computer -eq $env:ComputerName) {
                Invoke-Command -ScriptBlock $SB  -ArgumentList $VerbosePreference, $Quiet, $DisplayOnly
            } else {
                Invoke-Command -ComputerName $computer -ScriptBlock $SB  -ArgumentList $VerbosePreference, $Quiet, $DisplayOnly
            }

        } else {
            Write-Output "$($Computer.PadRight(15)) not available"
        }
    }
}

