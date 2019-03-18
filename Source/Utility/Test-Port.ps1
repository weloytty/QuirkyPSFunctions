[CmdletBinding()]
Param(
    [parameter(ParameterSetName = 'ComputerName', Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string[]]$ComputerName,
    [parameter(Mandatory = $true , Position = 1)]
    [int]$Port,
    [switch]$Quiet,
    [switch]$DisplayOnly
)


begin {
    
    $remoteServer = $ComputerName
    [bool] $returnValue = $false
    if ($VerbosePreference) {$Quiet = $false}

}

process {

    
    $test = New-Object System.Net.Sockets.TcpClient;
    
    Try {
        foreach ($server in $RemoteServer) {

            try {
                if (-not $Quiet) {Write-Host "Connecting to ${server}:${Port} (TCP).." -NoNewLine; }
                $test.Connect($server, $Port);
                $returnValue = $true
                if (-not $Quiet) {Write-Host ".successful"; }
            } catch {if (-not $Quiet) {Write-Host ".failed"; }}
        }
    } Catch {
        Write-Host "Error!"
    } Finally {
        $test.Dispose();
    }
    

}
end {

    if (-not $DisplayOnly) {
        return $returnValue
    }
    
}
