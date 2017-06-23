
throw "use Build.ps1"


$PROFILEROOT = Split-Path $PROFILE -Parent

if ($ProfileRoot -eq "") { throw "Can't find profile root" }

$Source = $(Split-Path $MyInvocation.MyCommand.Path -Parent)

if (-not (Test-Path $($source))) { throw "Can't find path $Source" }

$Destination = ($PROFILEROOT + "\Modules\Quirky")
$Destination = Join-Path $PROFILEROOT "Modules\Quirky"

if (-not (Test-Path "$Destination")) { New-Item -Path $Destination -ItemType Directory -Force }
$FileSystemDestination = $(Join-Path $Destination "FileSystem")
if (-not (Test-Path "$FileSystemDestination")) { New-Item -Path $FileSystemDestination -ItemType Directory -Force }

$UtilityDestination = $(Join-Path $Destination "Utility")
if (-not (Test-Path "$UtilityDestination")) { New-Item -Path $UtilityDestination -ItemType Directory -Force }

$InformationDestination = $(Join-Path $Destination "Information")
if (-not (Test-Path "$InformationDestination")) { New-Item -Path "$InformationDestination" -ItemType Directory -Force }

$TestDestination = $(Join-Path $Destination "Tests")
if (-not (Test-Path "$TestDestination")) { New-Item -Path "$TestDestination" -ItemType Directory -Force }



Copy-Item (Join-Path $Source "Quirky.psd1") (Join-Path $Destination "Quirky.psd1") -Force
Copy-Item (Join-Path $Source "Quirky.psm1") (Join-Path $Destination "Quirky.psm1") -Force
Copy-Item (Join-Path $Source "Quirky.Preferences.ps1") (Join-Path $Destination "Quirky.Preferences.ps1") -Force
Copy-Item (Join-Path $Source "FileSystem\Quirky.FileSystem.psm1") (Join-Path $Destination "FileSystem\Quirky.FileSystem.psm1") -Force
Copy-Item (Join-Path $Source "Utility\Quirky.Utility.psm1") (Join-Path $Destination "Utility\Quirky.Utility.psm1") -Force
Copy-Item (Join-Path $Source "Information\Quirky.Information.psm1") (Join-Path $Destination "Information\Quirky.Information.psm1") -Force
Copy-Item (Join-Path $Source "Tests\Quirky.Tests.ps1") (Join-Path $Destination "Tests\Quirky.Tests.psd1") -Force

Remove-Item $(Join-Path -Path $Destination -ChildPath "Quirky.Information.psm1") -ErrorAction SilentlyContinue
Remove-Item $(Join-Path -Path $Destination -ChildPath "Quirky.FileSystem.psm1") -ErrorAction SilentlyContinue
Remove-Item $(Join-Path -Path $Destination -ChildPath "Quirky.Tests.psm1") -ErrorAction SilentlyContinue
Remove-Item $(Join-Path -Path $Destination -ChildPath "Quirky.Utility.psm1") -ErrorAction SilentlyContinue
Remove-Item $(Join-Path -Path $Destination -ChildPath "*.pssproj") -ErrorAction SilentlyContinue
Remove-Item $(Join-Path -Path $Destination -ChildPath "*.vspcc") -ErrorAction SilentlyContinue
Remove-Item $(Join-Path -Path $Destination -ChildPath "*.bak") -ErrorAction SilentlyContinue
Remove-Item $(Join-Path -Path $Destination -ChildPath "Quirky.tests.ps1") -ErrorAction SilentlyContinue
Remove-Item $(Join-Path -Path $Destination -ChildPath "*deploy.ps1") -ErrorAction SilentlyContinue
Remove-Item $(Join-Path -Path $Destination -ChildPath "obj") -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $(Join-Path -Path $Destination -ChildPath "bin") -Recurse -Force -ErrorAction SilentlyContinue

#if((get-module personalfunctions) -ne $null){Remove-Module PersonalFunctions}
#if(Test-Path $PersonalFunctionsLocation -PathType Container){Remove-Item $PersonalFunctionsLocation -Force}

if ((Get-Module -Name Quirky) -ne $null)
{
  Remove-Module -Name Quirky -Force
}
Import-Module quirky -Verbose

