
  [CmdletBinding()]
  param(
	[Alias("Path")]
	[Parameter(Mandatory = $true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string]$FileName,
	[switch]$NoArguments
  )


  $command = $Global:QuirkyPreferences.Get_Item("EditorCommand")
  $arguments = $Global:QuirkyPreferences.Get_Item("EditorArguments")
  if ($arguments -eq $null) { $arguments = '' }
  Write-Verbose "Preferences editor is '$command'"
  Write-Verbose "Preferences arguments is '$arguments'"

  $expandedCommand = (Get-Command "notepad.exe").Source
  if ($command -eq $null) {
	$command = "notepad.exe"
	$arguments = ''
  }

  if (Get-Command "$command")
  {

	$expandedCommand = (Get-Command $command).Source
	Write-Verbose "$command expands to $expandedCommand"
  }

  if (Test-Path $fileName -PathType Leaf)
  {
	Write-Verbose "Expanding $fileName"
	$fileName = $(Get-Item $fileName | select -ExpandProperty FullName)
	Write-Verbose "File name is now $fileName"
  }


  $pushed = $false
  #if it starts with "Microsoft.PowerShell.Core\FileSystem::", it's a network path
  if ((Get-Location).Path.StartsWith("Microsoft.PowerShell.Core\FileSystem::"))
  {
	$pushed = $true
	Push-Location
	Write-Verbose "Setting Location to $expandedCommand"
	Set-Location $(Split-Path "$expandedCommand")

  }



  #Write-Verbose "Running `"$expandedCommand`" `"$fileName`" $($argments.Split(','))"

  & "$expandedCommand" "$fileName" $arguments.Split(',')

  if ($pushed)
  { Pop-Location }




