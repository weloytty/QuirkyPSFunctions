
[CmdLetBinding()]
param(
    [parameter(Mandatory = $True, ValueFromPipeline = $True, position = 0)]
    [Alias("VMName")]
    [string[]] $Name
)

begin {
    Set-StrictMode -Version Latest
    if ($Name -eq "") { $Name = $(Get-VM | Select-Object -Expand Name) }

}

process {
    foreach ($vm in $Name) {
        Get-VMNetworkAdapter -VMName $vm | Select-Object IpAddresses | ForEach-Object { Write-Output $_.IpAddresses }
    }
}

end
{}


