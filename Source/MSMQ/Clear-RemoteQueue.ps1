[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,
    [string]$QueueName,
    [ValidateSet("PrivateAndPublic", "Private", "Public", "SystemJournal", "SystemDeadLetter", "SystemTransactionalDeadLetter")]
    [string]$QueueType = "Private",
    [switch]$Journal)

begin {
    Set-StrictMode -Version Latest
    $ScriptBlock = {
        $thisQueue = Get-MSMQQueue -Name "$using:QueueName" -QueueType $using:QueueType -ErrorAction SilentlyContinue
        if ($thisQueue -eq $null) {
            Write-Output "Can't access '$QueueName' on $ComputerName"
        }
        [bool]$shouldClear = $false
        Write-Output "$($env:ComputerName.padRight(15)) Queue Count: $($thisQueue.MessageCount) Journal Count: $($thisQueue.JournalMessageCount)"
        $shouldClear = [bool]($thisQueue.JournalMessageCount -gt 0 -or $thisQueue.MessageCount -gt 0)
        if ($shouldClear ) {
            if ($using:Journal) {$thisQueue = Get-MSMQQueue -Name "$using:QueueName" -QueueType $using:QueueType -Journal}
            if ($thisQueue -ne $null) {
                $thisQueue|Clear-MSMQQueue 
            }

            
        }
    }

        

}

process {
    if (Test-Connection -ComputerName $ComputerName -Quiet -Count 1) {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock
    } else {Write-Output "$ComputerName unavailable"}
    
        
}
end {

}