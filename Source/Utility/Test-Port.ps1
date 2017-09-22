[CmdletBinding()]
Param(
    [parameter(ParameterSetName = 'ComputerName', Position = 0,Mandatory=$true)]
    [string]$ComputerName,
    [parameter(Mandatory = $true , Position = 1)]
    [int]$Port,
    [switch]$Quiet
)


begin {
    
    $remoteServer = $ComputerName
    [bool] $returnValue = $false
    if ($VerbosePreference) {$Quiet = $false}

}

process {

    $test = New-Object System.Net.Sockets.TcpClient;
    Try {
        if (-not $Quiet) {Write-Host "Connecting to "$RemoteServer":"$Port" (TCP).."; }
        $test.Connect($RemoteServer, $Port);
        $returnValue = $true
        if (-not $Quiet) {Write-Host "Connection successful"; }
    } Catch {
        if (-not $Quiet) {Write-Host "Connection failed"; }
    } Finally {
        $test.Dispose();
    }

}
end {
    return $returnValue
}
