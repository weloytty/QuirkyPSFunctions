[CmdletBinding()]
param(    [Parameter(ValueFromPipeline = $true, Position = 0)]
    [string[]]$Name ,
    [Parameter(ValueFromPipeline = $true, Position = 1)]
    [string[]]$ResourceGroupName ,
    [string]$azureSubscription,
    [switch]$ConnectToResource = $false
)

begin {
    Set-StrictMode -Version Latest
    Set-PSDebug -Strict -Trace 0
    $inputPosition = -1
    $resourceGroup = ""


    if ($PSVersionTable.PSVersion.Major -gt 5) {
        Import-Module AzureRM.Netcore
        Import-Module AzureRM.Profile.Netcore
    }

    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

}

process {
    $vms = get-azurermvm
    $nics = get-azurermnetworkinterface | where VirtualMachine -NE $null #skip Nics with no VM

    foreach ($nic in $nics) {
        $vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
        $prv = $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
        $alloc = $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
        Write-Output "$($vm.Name) : $prv , $alloc"
    }
}

end {
    
}