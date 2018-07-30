
[CmdletBinding()]
param([string[]]$ModuleName)

begin
{}

process
{
foreach($thisModuleName in $ModuleName){
 $dscResource = $(Get-DSCResource -Module $thisModuleName -ErrorAction SilentlyContinue)
		if($null -ne $dscResource)
		{
		  $modByName = @{}
		  $modbyName.Name = $thisModuleName
		  $modbyName.Properties = new-object 'System.Collections.Generic.Dictionary[string,Object]'

		  foreach($r in $dscResource)
		  {
			$thisItem = @{}
			$thisItem.Name = $r.Name
			$thisItem.CommandType = "DSCResource"
			$thisObject =  $(New-Object -Type PSObject -Property $thisItem)
			$modbyName.ExportedCommands.Add($thisItem.Name,$thisObject)
		  }
		}
		}
}

end
{
}

