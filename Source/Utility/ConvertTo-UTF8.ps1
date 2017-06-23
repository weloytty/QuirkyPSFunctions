
[CmdLetBinding()]
param(
	[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string[]]$FileName
)

begin
{
	Set-StrictMode -Version Latest
}

process
{
	foreach($file in $FileName)
	{
		$thisItem = Get-Item $File
		$a = Get-Content $($thisItem.FullName) -Enc Unicode
		Set-Content -Encoding UTF8 $($thisItem.FullName) -value $a
	}

}
