
[CmdletBinding()]
param([string[]]$FileName)

	begin
	{
		Set-StrictMode -Version Latest
	}
	process
	{
		foreach($file in $FileName)
		{

			[xml]$xml = Get-Content $file
			$StringWriter = New-Object System.IO.StringWriter
			$XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter
			$xmlWriter.Formatting = [System.Xml.Formatting]::Indented
			$xmlWriter.Indentation = $Indent
			$xml.WriteContentTo($XmlWriter)
			$XmlWriter.Flush()
			$StringWriter.Flush()
			Write-Output $StringWriter.ToString()
		}
	}



