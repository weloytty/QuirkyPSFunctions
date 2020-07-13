[CmdletBinding()]
Param(
    [parameter(Position = 0, Mandatory = $true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [string[]]$ComputerName,
    [parameter( Position = 1)]
    [int]$Port = 3389,
    [switch]$Quiet
)


begin {

    $remoteServer = $ComputerName
    [bool] $returnValue = $false
    if ($VerbosePreference) {$Quiet = $false}
}

process {
Write-Verbose "Processing $remoteServer"
    foreach ($r in $remoteServer) {
        Write-Verbose "$r"
        $test = New-Object System.Net.Sockets.TcpClient;
        Try {
            $rd = $r.PadRight(15)
            if (-not $Quiet) {Write-Host "Connecting to "$rd":"$Port" (TCP)..." -NoNewLine; }
            $test.Connect($r, $Port);
            $returnValue = $true
            if (-not $Quiet) {Write-Host "...succeeded."; }
        } Catch {
            if (-not $Quiet) {Write-Host "...failed."; }
        } Finally {
            $test.Dispose();
        }
    }
}
end {
    $returnValue
}
