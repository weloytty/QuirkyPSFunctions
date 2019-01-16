
param([string[]]$ComputerName = "localhost",
    [string[]]$UserName)
$results = @()
foreach ($computer in $ComputerName) {
    if (Test-Port -ComputerName $Computer -Quiet -Port 3389) {
        $shells = Get-WSManInstance -ConnectionUri "http:`/`/$($Computer):5985/wsman" shell -enum
        $results = $shells
        if ($null -ne $UserName -and $UserName.Length -gt 0) { $results = $null }
        foreach ($user in $UserName) {
            $results += $($shells | Where-Object { $_.Owner -eq $user })
        }

    } else { Write-Output "Can't connect to $computer" }

}
return $results


