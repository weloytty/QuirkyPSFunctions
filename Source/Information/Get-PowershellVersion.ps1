
[CmdletBinding()]
param(
    [Alias("FQDN")]
    [Parameter(ValueFromPipeline = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
    [string[]]$ComputerName = $env:COMPUTERNAME,
    [switch]$DisplayOnly,
    [switch]$Quiet)
begin {
    
    Set-StrictMode -Version Latest

    $rv = @()

    $ScriptToRun = {

        $VerbosePreference = $using:VerbosePreference
        Write-Verbose "Running on $($env:computername)"
        Write-Verbose "Display Only is set to $($using:DisplayOnly)"
        Write-Verbose "Quiet is set to $($using:Quiet)"

        if ($using:Quiet -and $using:DisplayOnly) {
            Write-Verbose "Quiet and DisplayOnly were both set, no output will be produced"
        }

        $paddedName = $($Env:ComputerName).padRight(15)

        if ($using:Quiet -eq $false) {
            Write-Output "$paddedName is running Powershell Version $($PSVersionTable.PSVersion) on CLR $($PSVersionTable.CLRVersion)"
        }

        $returnObject = New-Object -Type psobject -Property $PSVersionTable
        if ($using:DisplayOnly) {
            $ReturnObject = $null
        }


        $returnObject
    }
}
process {

    foreach ($server in $ComputerName) {
        Write-Verbose "Processing $server"
        $retVal = $null

if($Env:ComputerName -eq $server){$server = 'localhost'}

        Invoke-Command -ComputerName $server -ScriptBlock $ScriptToRun -EnableNetworkAccess -OutVariable retVal
        $rv += $retVal
    }
}
end {
    if($DisplayOnly){$rv=$null}
    $rv
}
