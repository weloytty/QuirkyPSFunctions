[CmdletBinding()]
param(
    [string[]]$ProcessName,
    [int]$ProcessID,
    [switch]$Bare)

begin {
    Set-StrictMode -Version Latest
    Write-Verbose "ProcessID=$ProcessID"
    Write-Verbose "ProcessID=$ProcessName"
    if ($processId -ne 0 -and $null -ne $ProcessName ) {throw "Ambiguous Arguments:  You can't ask for both a PID and processname"}

}
process {


    if (-not $Bare) {
        Write-Output "$($("ProcessName").padRight(25))$($("ProcessID").PadRight(15))User"
        Write-Output "$("-" * 44)"    
    }
    #break this out into a function, but I have shit to do!
    if ($processID -gt 0) {
        $pInfo = $(Get-CimInstance Win32_Process|Where-Object processid -eq $processID)

    }
    if ($null -ne $ProcessName ) {
        
        foreach ($pn in $processName) {
            $pInfo = $(Get-CimInstance Win32_Process -Filter "Name='$pn'"    )
            if ($null -ne $pInfo) {
                foreach ($thisInfo in $pInfo) {
                    $outputInfo = Invoke-CimMethod -InputObject $thisInfo -MethodName GetOwner    
                    Write-Output "$($($thisInfo.Name).padRight(25))$($($thisInfo.ProcessId.ToString()).padRight(15))$($outputInfo.Domain)\$($outputInfo.User)"
                }

                
            }

        }
        
    }
    
}
