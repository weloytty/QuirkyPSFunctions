#
# Quirky.psm1
#
function Get-ModuleFunctions ()
{
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true,Position = 0,ValueFromPipelineByPropertyName=$true)]
	[string[]]$Name,
	[ValidateSet('CmdLet','Alias','Function','Filter','All')]
	[string]$CommandType = 'All',
	[switch]$Quiet,
	[switch]$DisplayOnly
  )

  begin
  {
	Set-StrictMode -Version Latest
	$returnAlias = @{}
	$returnFunction = @{}
	$returnFilter = @{}
	$returnCmdLet = @{}
	$returnValue = @()
  }
  process
  {

	if ($Quiet -and $DisplayOnly)
	{
	  Write-Verbose "Quiet and DisplayOnly are both set.  No output will be produced"
	}

	$ModuleName = $Name

	if ($null -ne $ModuleName)
	{
	  foreach ($thisModuleName in $ModuleName)
	  {
		Write-Verbose "Processing module $thisModuleName"
		$return = @{}
		$return.Module = ""
		$return.FunctionInfo = @()
		$return.AliasInfo = @()
		$return.FilterInfo = @()
		$return.CmdletInfo = @()

		if ($thisModuleName -ne "Quirky")
		{
		  Import-Module -Name $thisModuleName -ErrorAction SilentlyContinue
		}



		$modbyName = $(Get-Module -Name $thisModuleName -ErrorAction SilentlyContinue)
		if ($modByName -eq $null)
		{
		  $modbyName = $(Get-Module -Name $thisModuleName -ListAvailable -ErrorAction SilentlyContinue)
		}

		if ($modByName -eq $null)
		{
		  #if there are multiple versions of a module, this will load the latest

		  $modbyName = $(Get-Module -Name $thisModuleName -ErrorAction SilentlyContinue)
		}




		if ($null -ne $modByName)
		{

		  if ([bool]($modbyName.PSObject.Properties.Name -match "Count"))
		  {
			if ($modbyName.Count -gt 1)
			{

			  $modByName = Get-HighestModuleVersion $modByName -Verbose:$VerbosePreference
			}
		  }


		  $return = @{}
		  $return.Module = $modByName.Name
		  $return.FunctionInfo = @()
		  $return.AliasInfo = @()
		  $return.FilterInfo = @()
		  $return.CmdletInfo = @()
		  $return.ResourceInfo = @()

		  if (($modByName.ExportedCommands -ne $null) -and ($modByName.ExportedCommands.Values -ne $null))
		  {
			Write-Verbose "Module is not null, getting exported commands"
			if ($modbyName.ExportedCommands -ne $null -and $modbyName.ExportedCommands.Values -ne $null)
			{
			  $functionByName = $($modbyName.ExportedCommands.Values.Name)
			}
			if ($($modbyName.ExportedDscResources -ne $null))
			{
			  $functionsByName += $($modbyName.ExportedDscResources.Values.Name)
			}

			if ($VerbosePreference) { Write-Verbose $($modByName |% {Write-Verbose $("$($_.CommandType) $($_.Name)")}) }

			if ($CommandType -ne 'All')
			{
			  $functionByName = $($functionByName | Where-Object { $_.CommandType -eq $CommandType })
			}
			$functionByName = $($functionByName | Sort-Object CommandType,Name)


			$return.Module = $modByName.Name
			$return.FunctionInfo = @()
			$return.AliasInfo = @()
			$return.FilterInfo = @()
			$return.CmdletInfo = @()




			$testModule = Get-Module -Name $thisModuleName -ErrorAction SilentlyContinue
			$imported = $false
			if ($null -eq $testModule)
			{
			  Import-Module -Name $thisModuleName
			  $imported = $true
			}

			#
			#for($counter=0;$counter -lt $($modbyName.ExportedCommands.Count);$counter++)
			$functionNumber = -1
			foreach ($g in $functionByName)
			{

			  $functionNumber++
Write-Verbose "Working on function $g Number $functionNumber"
			  $f = $(Get-Command $modByName.ExportedCommands[$g] -ErrorAction SilentlyContinue)



			  if ($f -eq $null)
			  {
				Write-Verbose "Getting Command by function number $functionNumber"
				$f = $(Get-Command $modByName.ExportedCommands[$functionNumber] -ErrorAction SilentlyContinue)
			  }


			  Write-Verbose "Getting information for $f"


			  [hashtable]$commandInfo = @{}
			  $commandInfo.CommandType = $f.CommandType
			  $commandInfo.Name = $f.Name
			  #$returnList += $(New-Object -Type PSObject -Property $commandInfo)

			  Write-Verbose "Command Type $($f.CommandType)"
			  switch ($f.CommandType)
			  {
				"Function" { $return.FunctionInfo += $(New-Object -Type PSObject -Property $commandInfo) }
				"Alias" {
				$aliasInfo = $(Get-Command $f -ErrorAction SilentlyContinue)


				if($aliasInfo -ne $null){

					if ([bool]($commandInfo.PSobject.Properties.name -match "ResolvedCommand"))
					{
				  $commandInfo.ResolvedCommand = $($aliasInfo| Select -ExpandProperty ResolvedCommand)
				  $return.AliasInfo += $(New-Object -Type PSObject -Property $commandInfo)
				  $aliasInfo = $null

					}
				  }
				}
				"Filter" { $return.FilterInfo += $(New-Object -Type PSObject -Property $commandInfo) }
				"Cmdlet" { $return.CmdletInfo += $(New-Object -Type PSObject -Property $commandInfo) }

				default { Write-Host "Unknown CommandType $($f.CommandType) for $($f.Name)" }
			  }



			}

			if ($imported) { Remove-Module -Name $modByName -ErrorAction SilentlyContinue }

		  } else { Write-Verbose "No exported commands in $thisModuleName" }
		}
		$returnValue += $(New-Object -Type PSObject -Property $return)



	  }
	}
  }
  end
  {

	function WriteInformation ()
	{
	  param($functionGroup)

	  $headerWritten = $false
	  foreach ($a in $functionGroup | Sort-Object Name)
	  {
		if (-not $headerWritten)
		{
		  $headerWritten = $true
		  Write-Host "$($a.CommandType.ToString().padRight(10))"
		  Write-Host "----------"
		}
		Write-Host "$($a.CommandType.ToString().padRight(10)) $($a.Name.ToString())"
	  }
	  if ($headerWritten) { Write-Host "" }
	}

	if (-not $Quiet)
	{
	  Write-Host ""
	  foreach ($s in $returnValue)
	  {
		$headerWritten = $false
		foreach ($a in $s.AliasInfo)
		{
		  if (-not $headerWritten)
		  {
			$headerWritten = $true
			Write-Host "$($a.CommandType.ToString().padRight(10))"
			Write-Host "----------"
		  }
		  $t = $a.CommandType.ToString().padRight(10)
		  $n = $a.Name.ToString()
		  $r = $a.ResolvedCommand.ToString()
		  Write-Host "$t $n ($r)"

		}
		if ($headerWritten) { Write-Host "" }

		WriteInformation ($s.FunctionInfo)
		WriteInformation ($s.CmdletInfo)
		WriteInformation ($s.FilterInfo)



	  }



	}
	if ($DisplayOnly) { $returnValue = $null }

	return $returnValue
  }
}
Set-Alias gmf -Value Get-ModuleFunctions


function Get-CommandSource ()
{
  [CmdletBinding()]
  param(
	[Alias('Name')]
	[Parameter(Mandatory = $true)]
	[string]$CommandToFind,
	[switch]$Details
  )
  $a = Get-Command $CommandToFind -ErrorAction SilentlyContinue
  if ($a -ne $null)
  {
	$article = 'a'
	if ($a.CommandType -eq 'Alias' -or $a.CommandType -eq 'Application') { $article = 'an' }
	Write-Verbose "$CommandToFind is $article $($a.CommandType)"
	switch ($a.CommandType)
	{
	  "Application" { $output = $a.Source }
	  "CmdLet" { $output = $a.Source }
	  "Filter" { $output = $a.Source }
	  "ExternalScript" { $output = $a.Source }
	  "Alias" {
		$def = $a | Select-Object -ExpandProperty Definition
		Write-Verbose "$CommandToFind is an alias for $def"
		if ($def -ne $null)
		{
		  $output = Get-CommandSource -CommandToFind $def -Details:$Details
		}

	  }
	  default { $output = $a.Source }
	}
	Write-Output $output
  }

}
Set-Alias whereis -Value Get-CommandSource


function Find-CommandSourceCode ()
{
  [CmdletBinding()]
  param(
	[string[]]$Name
  )
  begin
  {
	Set-StrictMode -Version Latest
	$arrayToReturn = @()
  }
  process
  {

	foreach ($commandName in $name)
	{


	  $sourceFile = ''
	  $binaryFile = $false
	  Write-Verbose "Finding $commandName"

	  $command = (Get-Command $commandName -ErrorAction SilentlyContinue)

	  if ($command -eq $null) { throw "Can't find $commandName" }

	  if ($command.CommandType -eq "Alias")
	  {
		$expandedCommand = $(Get-Alias $command).Definition
		Write-Verbose "Expanded alias $command to $expandedCommand"
		$command = $(Get-Command $expandedCommand)
	  }


	  Write-Verbose "$($command.Name) source is from $($command.Source), which is a $($command.CommandType)"


	  if (($command.CommandType -eq "Function") -or ($command.CommandType -eq "Filter"))
	  {
		$module = $command.Source

		if ($module -eq "Quirky.Module") { $module = "Quirky" }

		Write-Verbose "Module is $module"
		if ($module -ne "" -and $module -ne $null)
		{

		  if ($module -ne "Quirky") { Import-Module -Name $module }

		  Write-Verbose "Getting Module $module"

		  $sourceFile = $(Get-Module $module).Path

		  Write-Verbose "Source to $($command.Name) appears to be $($sourceFile)"

		  $thisModule = Get-Mogdule $module
		  $thisModule = Get-HighestModuleVersion($thisModule)

		  if ($thisModule.NestedModules.Count -gt 0)
		  {
			Write-Verbose "BUT, $(Split-Path $sourceFile -Leaf) has NestedModules!"
			Write-Verbose "dunDunDUNNNNNNNN.jpg"
			if ($thisModule.ExportedFunctions[$command].Source -ne $module)
			{
			  Write-Verbose "Nested module is $($thisModule.ExportedCommands[$command].Module.Name), which is a $($thisModule.ModuleType)"
			  if ($thisModule.ModuleType -eq "Script") {
				$sourceFile = $thisModule.ExportedFunctions[$command].Module.Path
			  } else {
				Write-Verbose "I don't know what to do with $($thisModule.ModuleType)"
			  }
			}
		  } else {
			Write-Verbose "Can't find a source for $($command.Name), using profile"
			if ($sourceFile -eq '') { $sourceFile = $PROFILE }
		  }
		} else {
		  Write-Verbose "Can't find a source for $($command.Name).  Returning $PROFILE"
		  if ($sourceFile -eq $null -or $sourceFile -eq '')
		  {
			if (Test-Path $PROFILE)
			{
			  $sourceFile = $PROFILE
			}
		  }
		}


		Write-Verbose "Source: `'$sourceFile`'"

		if (($sourceFile -ne '') -and (-not (Test-Path $sourceFile)))
		{
		  Write-Verbose "Test-Path $sourceFile returns $(Test-Path $sourceFile)"
		  $sourceFile = $null
		}


	  }
	  if ($command.CommandType -eq "CmdLet")
	  {
		$sourceFile = $command.DLL
		$binaryFile = $true
	  }
	  if ($command.CommandType -eq "ExternalScript")
	  {
		$sourceFile = $command.Source

	  }

	  [hashtable]$returnValues = @{}

	  if (($sourceFile -ne $null) -and ($sourceFile -ne '')) {
		$returnValues.FileInfo = $(Get-Item $sourceFile)
		$returnValues.Definition = $command.Definition
	  } else {
		$returnValues.FileInfo = $null
	  }
	  if ($binaryFile -eq $false)
	  {
		$returnValues.Path = $sourceFile
	  }


	  $arrayToReturn += $(New-Object -Type psobject -Property $returnValues)
	}



  }
  end
  {
	return $arrayToReturn
  }
}
Set-Alias gms -Value Find-CommandSourceCode


function Get-HighestModuleVersion ()
{
  [CmdletBinding()]
  param([System.Management.Automation.PSModuleInfo[]]$thisModule)

  Write-Verbose "There are $($thisModule.Count) versions of $($thisModule[0].Name)"
  if ($VerbosePreference)
  {
	for ($i = 0; $i -lt $thisModule.Count; $i++)
	{
	  Write-Verbose "$($thisModule[$i].Version)"
	}
  }

  $returnValue = $thisModule
  if ($thisModule.Count -gt 1) {
	$savedMajor = 0
	$savedMinor = 0
	$savedBuild = 0
	$savedRevision = 0
	for ($thisIndex = 0; $thisIndex -lt $thisModule.Count; $thisIndex++)
	{
	  if ($thisModule[$thisIndex].Version.Major -gt $savedMajor)
	  {
		$savedMajor = $thisModule[$thisIndex].Version.Major
		$highestIndex = $thisIndex
	  }
	  if ($highestIndex -ne $thisIndex)
	  {
		if ($thisModule[$thisIndex].Version.Minor -gt $savedMinor)
		{
		  $savedMinor = $thisModule[$thisIndex].Version.Minor
		  $highestIndex = $thisIndex
		}

	  }

	  if ($highestIndex -ne $thisIndex)
	  {
		if ($thisModule[$thisIndex].Version.Build -gt $savedBuild)
		{
		  $savedBuild = $thisModule[$thisIndex].Version.Build
		  $highestIndex = $thisIndex
		}

	  }

	  if ($highestIndex -ne $thisIndex)
	  {
		if ($thisModule[$thisIndex].Version.Revision -gt $savedRevision)
		{
		  $savedRevision = $thisModule[$thisIndex].Version.Revision
		  $highestIndex = $thisIndex
		}

	  }
	} #for($thisIndex = 0;$thisIndex -lt $thisModule.Count;$thisIndex++)
	$returnValue = $thisModule[$highestIndex]
  } #if($thisModule.Count -gt 1){

  Write-Verbose "Returning highest version, version $($returnValue.Version)"
  return $returnValue
}

function Edit-Command ()
{
  [CmdletBinding()]
  param(
	[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true)]
	[string]$CommandName
  )
  begin
  {
	Set-StrictMode -Version Latest
  }

  process
  {

	$file = Find-CommandSourceCode -Name $CommandName -Verbose:$VerbosePreference
	Write-Verbose "Find-CommandSource returned '$file'"
	if ($file.Path -ne '' -and $file.Path -ne $null)
	{
	  Edit-File -FileName "$($file.Path)" -Verbose:$VerbosePreference
	} else { Write-Error "Can't find source for $CommandName" }

  }
}
Set-Alias edc Edit-Command

function Set-LocationToModuleFolder
{
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string]$ModuleName,
	[switch]$StayIfNotFound
  )

  begin
  {
	Set-StrictMode -Version Latest
  }

  process
  {

	$pathToSet = $env:PSModulePath -split ";" -match $env:USERNAME

	Write-Verbose "Path to set is originally $pathToSet"
	Write-Verbose "Looking for $ModuleName"

	if ($ModuleName.Length -gt 0) {
	  Write-Verbose "Invoking Get-Module -Name $ModuleName -ErrorAction SilentlyContinue"
	  $thisModule = $(Get-Module -Name "$ModuleName" -ErrorAction SilentlyContinue)

	  if ($thisModule -eq $null)
	  {
		Write-Verbose "Can't find $ModuleName. Trying Get-Module with -ListAvailable"
		$thisModule = Get-Module -Name $ModuleName -ListAvailable -ErrorAction SilentlyContinue
	  }

	  if ($thisModule -eq $null)
	  {
		Write-Verbose "Can't find $ModuleName. Trying Get-DSCResource "
		$thisModule = Get-DscResource -Module $ModuleName -ErrorAction SilentlyContinue
	  }

	  if ($thisModule -ne $null) {
		$count = $thisModule | Measure-Object | Select -ExpandProperty Count
		if ($count -gt 1)
		{
		  Write-Verbose "There are $count versions of $ModuleName"
		  if ($VerbosePreference)
		  {
			for ($i = 0; $i -lt $count; $i++)
			{
			  Write-Verbose "$($thisModule[$i].ModuleBase)"
			}
			Write-Verbose ""
		  }
		  $thisModule = $thisModule[0]
		}
		Write-Verbose "Setting to $thisModule at $($thisModule.Path)"
		$pathToSet = Split-Path -Parent $thisModule.Path
	  } else {
		if ($StayIfNotFound) { $pathToSet = '' }
	  }
	}
	if ($pathToSet.Length -gt 0)
	{
	  Write-Verbose "Setting Path $pathToSet"
	  Set-Location "$pathToSet"
	}

  }
}
Set-Alias -Name slm -Value Set-LocationToModuleFolder

function Get-Properties ()
{
  [CmdletBinding()]
  param(
	[Parameter(ValueFromPipeline = $true,Position = 0)]
	[object]$InputObject)
  Write-Verbose "Input Object Type: $($InputObject.GetType())"
  [hashtable]$output = @{}
  foreach ($member in $InputObject.PSObject.Properties)
  {

	Write-Output "$($member.Name.padRight(30)) $($InputObject.$($member.Name))"
  }
}

function Start-DebugPowerShell
{
  PowerShell -NoProfile -NoExit -Command {
	function prompt {
	  $newPrompt = "$pwd.Path [DEBUG]"
	  Write-Host -NoNewline -ForegroundColor Yellow $newPrompt
	  return '> '
	}
  }
}
Set-Alias -Name sdp -Value Start-DebugPowerShell



function Show-ParseStatus ()
{
  [CmdletBinding()]
  param(
	[Parameter(Mandatory = $true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
	[string[]]$FileName,
	[switch]$Quiet
  )

  begin
  {
	Set-StrictMode -Version Latest
	$returnValue = @()
  }

  process
  {
	foreach ($file in $FileName)
	{
	  if (Test-Path $file -PathType Leaf)
	  {
		$item = Get-Item $file | Select -ExpandProperty FullName
		[hashtable]$results = @{}
		$results.Name = $(Get-Item $item | Select -ExpandProperty Name)
		$results.FullName = $item
		$results.Parses = $false
		$tokens = $null
		$parseErrors = $null
		Write-Host $item

		$ast = [System.Management.Automation.Language.Parser]::ParseFile($item,[ref]$tokens,[ref]$parseErrors)
		foreach ($err in $parseErrors)
		{
		  Write-Host $err
		}
		$results.Tokens = $tokens
		$results.ParseErrors = $parseErrors
		if ($parseErrors.Count -eq 0)
		{
		  $results.Parses = $true
		}
		if ($Quiet)
		{
		  $returnValue += $results.Parses
		} else {
		  $returnValue += New-Object -Type PSObject -Property $results
		}



	  }
	}
  }

  end
  {
	return $returnValue
  }

}
Set-Alias check -Value Show-ParseStatus


