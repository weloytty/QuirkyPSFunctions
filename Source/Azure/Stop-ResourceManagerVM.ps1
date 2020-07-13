[CmdletBinding()]
param([string]$Name = $(throw "VM Name Required."),
    [string]$ResourceGroupName = $(throw "ResourceGroup required."),
    [string]$AzureSubscription
)



if ($PSVersionTable.PSVersion.Major -gt 5) {
    Import-Module AzureRM.Netcore
    Import-Module AzureRM.Profile.Netcore
}

$vmname = $name
$resourcegroup = $ResourceGroupName
$vm = $null
try {
    $vm = Get-AzureRmVM -ResourceGroupName $resourcegroup -Name $vmname -Status -ErrorAction Stop
} catch {
    Write-Output "Logging into Azure"
    if (($null -eq $AzureSubscription) -or ($AzureSubscription -eq '')) {
        $azureSubscription = $Global:QuirkyPreferences.Get_Item("AzureSubscription")
    }
    Write-Verbose "Logging in using subscription '$azureSubscription'"
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
		
    Login-AzureRmAccount



    Get-AzureRmSubscription -SubscriptionName $AzureSubscription | Select-AzureRMSubscription
    $vm = Get-AzureRmVM -ResourceGroupName $resourcegroup -Name $vmname -Status
}

if ($null -eq $vm) { throw "Can't get Azure VM" }

$status = $vm | `
    Select-Object -ExpandProperty Statuses | `
    Where-Object { $_.Code -match "PowerState" } | `
    Select-Object -ExpandProperty displaystatus


$currentTitle = $host.UI.RawUI.WindowTitle
if ($currentTitle.endsWith("Azure")) {
    $host.UI.RawUI.WindowTitle = $currentTitle.Replace(" Azure", "")
}


Write-Output "VM Status is $status"
if ($status -eq "VM running") {

    Write-Output "Stopping VM"
    Stop-AzureRmVM -Name $vmname -ResourceGroupName $resourcegroup -Force
}






