
	[CmdLetBinding()]
	param([string[]] $VMName)

	begin
	{}

	process 
	{
		foreach($vm in $VMName)
		{
			Get-VMNetworkAdapter -VMName $vm|Select-Object IpAddresses|Foreach-Object {$_.IpAddresses}
		}
	}

	end
	{}


