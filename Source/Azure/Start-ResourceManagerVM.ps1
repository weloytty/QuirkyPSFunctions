

  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true,Position = 0)]
	[string[]]$Name = $(throw "VM Name Required."),
	[Parameter(ValueFromPipeline = $true,Position = 1)]
	[string[]]$ResourceGroupName = $(throw "ResourceGroup required."),
	[string]$azureSubscription,
	[switch]$ConnectToResource = $false
  )

  begin {
	Set-StrictMode -Version Latest
	Set-PSDebug -Strict -Trace 0
	$inputPosition = -1
	$resourceGroup = ""
  }

  process {

	$inputPosition++

	foreach ($vmname in $name) {

	  if ($ResourceGroupName.Count -ge $inputPosition) {
		$resourcegroup = $ResourceGroupName[$inputPosition]
	  }

	  Write-Host "Starting VM $vmname in ResourceGroup $ResourceGroup"
	  $vm = $null
	  try {
		$vm = Get-AzureRmVM -ResourceGroupName $resourcegroup -Name $vmname -Status -ErrorAction Stop
	  } catch {
		Write-Verbose "Logging into Azure"

		if (($AzureSubscription -eq $null) -or ($AzureSubscription -eq '')) {
		  $azureSubscription = $Global:QuirkyPreferences.Get_Item("AzureSubscription")
		}

		login-azurermaccount



		Get-AzureRmSubscription -SubscriptionName $azureSubscription | Select-AzureRMSubscription
		$vm = Get-AzureRmVM -ResourceGroupName $resourcegroup -Name $vmname -Status
	  }

	  if ($vm -eq $null) { throw "Can't get Azure VM $vmname in $resourcegroup for subscription $SubscriptionName " }


	  $currentTitle = $host.UI.RawUI.WindowTitle
		if(-not $currentTitle.endsWith("Azure"))
		{
			$currentTitle+=" Azure"
			$host.UI.RawUI.WindowTitle = $currentTitle
		}


	  $status = $vm | `
		 select -ExpandProperty Statuses | `
		 Where-Object { $_.Code -match "PowerState" } | `
		 select -ExpandProperty displaystatus

	  Write-Verbose "VM Status is $status"
	  if ($status -ne "VM running") {
		Write-Host "Starting VM $vmname"
		Start-AzureRmVM -Name $vmname -ResourceGroupName $resourcegroup
	  }



	  $ipAddress = (Get-AzureRmPublicIpAddress -Name $vmname -ResourceGroupName $resourcegroup).IpAddress
	  Write-Verbose "Ip Address for VM is $ipAddress"

	  if ($ConnectToResource) {
		& mstsc /v:$ipAddress
	  } else {
		Write-Host "$vmname in $resourcegroup IpAddress $ipAddress"
		#PSCX has a Set-Clipbboard that clobbers the built in one.
		#So we make sure we use the built in one for people who
		#dont have PSCX
		Microsoft.PowerShell.Management\Set-Clipboard $ipAddress
		Write-Verbose "Ip Address copied to clipboard."
	  }

	  $vm = Get-AzureRmVM -ResourceGroupName $resourcegroup -Name $vmname -Status -ErrorAction Stop

	  $status = $vm | `
		 select -ExpandProperty Statuses | `
		 Where-Object { $_.Code -match "PowerState" } | `
		 select -ExpandProperty displaystatus

		[hashtable]$returnValues = @{}
	  $returnValues.IpAddress = $ipAddress
	  $returnValues.Status = $status
	  $returnValues.VM = $vm

	  $returnObject = New-Object psobject -Property $returnValues

	  return $returnObject
	}
  }


