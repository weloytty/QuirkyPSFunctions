[CmdletBinding(DefaultParameterSetName = 'UseAddress')]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, ParameterSetName = 'UseAddress')]
    [string]$Computername ,
    [Parameter(ValueFromPipelineByPropertyName = $true, Position = 1, ParameterSetName = 'UseAddress')]
    [int]$Port = 3389,
    [Parameter(ValueFromPipelineByPropertyName = $true, Position = 2, ParameterSetName = 'UseAddress')]
    [switch]$SkipTestConnection = $false,
    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'UseRDPFile')]
    [string]$RDPFile

)
begin {
    Set-StrictMode -version Latest
    $hostName = $ComputerName
    if ($Computername.ToUpper() -eq "CLIP") { $hostName = $(Get-Clipboard) }
}
process {
    
    Write-Verbose "New RDP session to $ComputerName on port $Port"
    

    if ($hostname -ne $ComputerName) {
        Write-Verbose "Converted $ComputerName to $hostName"
    }
    $fullRDPPath = ''
    if ($RDPFile -ne '') {
        if (-not (Test-Path $rdpFile)) {throw "Can't find rdp file $rdpFile"}
        $SkipTestConnection = $true
        $fullRDPPath = Get-Item $RDPFile|Select-Object -ExpandProperty FullName
    }

    if ($SkipTestConnection -eq $false) {

        try {
            if ($hostname -match "^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$" -or $hostname -match "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))") {


                $isIP4 = $( $hostname -match "^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$" )


                Write-Verbose "Parsing $hostname to validate IP Address format"
                $address = [System.Net.IPAddress]::parse($hostname)
                $output = "`"{0}`" is a valid IP address" -f $address.IPaddressToString
        
                Write-Verbose $output
                $hostname = $address.IPaddressToString
                if (-not $isIP4) {$skipTestConnection = $true}
                $octets = $hostname.Split(".")
        
                $publicIP = $octets[0] -ne 10

                #skip private IP Addresses 
                if (-not $SkipTestConnection) {
                    $skipTestConnection = $false
                    if (($octets[0] -eq "10") `
                            -or ($octets[0] -eq "172" -and $octets[1] -eq "16") `
                            -or ($octets[0] -eq "192" -and $octets[1] -eq "168" -and $octets[2] -eq "0")) {
                        Write-Verbose "Will not test connection to non-private IP"
                        $SkipTestConnection = $true
                    }
                }
            }
            Write-Verbose "Testing connectivity to $hostname"
            if (($SkipTestConnection -eq $false) -and (Test-Port -ComputerName $hostname -Port $Port -Quiet) -eq $false) {
                throw "Can't verify host $hostname"
                
            }

        } catch {
            Write-Output "Error validating hostname"
            foreach ($s in $error) {
                Write-Verbose $s
            }

        }
    } else { Write-Verbose "Not testing for connectivity to $hostname" }

    if ($fullRDPPath -ne '') {
        mstsc $fullRDPPath
    } else {
        if ($SkipTestConnection -or (Test-Port -Computername $hostname -Quiet -Port $Port)) {
            Write-Verbose "Invoking mstsc"
            $PortParameter = ":$Port"
            mstsc /v:$hostName$PortParameter
        }
  
    }
  


}

<#
.SYNOPSIS
    Opens a new RDP connection to a given IP Address
.DESCRIPTION
    Starts a new RDP session with a given computer. Contains
    Various aliases for computers I can never remember the names of
.PARAMETER ComputerName
    Computer to connect to
.PARAMETER SkipTestConnection
    By default, the function tries to test the connection to remote resource
    before conneecting. Set this flagset it to false if you're connecting to 
    a resource that is not pingable
.INPUTS 
    
    System.String
    You can pipe a string that contains the resource to connect to to New-RDPSession
     
.EXAMPLE
    New-RDPSession myserver
    
    Opens a connection to myserver after testing to make sure that the 
    server is reachable
    
.EXAMPLE

    New-RDPSerssion punedev
    Will open a conenction to the Pune development server
    (After testing to make sure it's there)
    
.EXAMPLE

    New-RDPSession 192.168.0.1 -SkipTestConnection
    Connects to ip address 192.168.0.1 without pinging it first
    
#>
