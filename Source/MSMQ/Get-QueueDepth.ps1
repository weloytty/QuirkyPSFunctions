[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,
    [string]$QueueName,
    [ValidateSet("PrivateAndPublic", "Private", "Public", "SystemJournal", "SystemDeadLetter", "SystemTransactionalDeadLetter")]
    [string]$QueueType = "Private")

begin {

    Set-StrictMode -Version Latest

    $ScriptBlock = {
        $thisQueue = Get-MsmqQueue -Name "$using:QueueName" -QueueType $using:QueueType -ErrorAction SilentlyContinue
        if ($thisQueue -eq $null) {
            Write-Output "Can't access '$QueueName' on $ComputerName"
        }
        Write-Output "$($env:ComputerName.padRight(15)) Queue Count: $($thisQueue.MessageCount) Journal Count: $($thisQueue.JournalMessageCount)"
    }

}

process {
    if (Test-Connection -ComputerName $ComputerName -Quiet -Count 1) {
        Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock
    } else { Write-Output "$ComputerName unavailable" }
 }
end {

}