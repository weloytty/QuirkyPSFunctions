#Requires -Version 5.0

#
# build.ps1
#

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string[]]$TaskList,
    [string]$ScriptPath
)

Set-StrictMode -Version Latest


$thisPath = $(Split-Path $MyInvocation.MyCommand.Source -Parent)

Write-Verbose "Path is $thisPath"
if ($ScriptPath -eq '') { $scriptPath = Join-Path $thisPath "defaultPSake.ps1" }
if ($TaskList -eq $null) { $TaskList += 'default' }


Push-Location


Set-Location $thisPath

Write-Verbose "Looking for Pester"
$pester = Get-Module -Name Pester
if (-not ($pester)) {
    Write-Verbose "Pester not available, trying again"
    $pester = Get-Module -ListAvailable -Name Pester
}
if (-not ($pester)) {
    Write-Verbose "Getting Pester from OneGet"
    Find-Module -Name Pester | Install-Module -Verbose
}

Write-Verbose "Looking for PSake"
$psake = Get-Module -Name PSake
if (-not ($psake)) {
    Write-Verbose "PSake not available, trying again"
    $psake = Get-Module -ListAvailable -Name Psake
}

if (-not ($psake)) {
    Write-Verbose "Getting Psake from OneGet"
    Find-Module -Name PSake | Install-Module -Verbose
}

Write-Verbose "Loadking Modules"
Import-Module PSAke
Import-Module Pester

Write-Host ""
Write-Host "Building Module Quirky"
Write-Host "Options:"
Write-Host "   BuildFile: $ScriptPath"
Write-Host "   TaskList : $taskList"
Write-Host "Invoking Invoke-psake `n  -buildFile $ScriptPath `n  -taskList $taskList `n  -Verbose:$VerbosePreference"
Write-Host ""

$thisTimer = New-Object System.Diagnostics.StopWatch
$thisTimer.Reset()
$thisTimer.Start()

Invoke-psake -buildFile "$ScriptPath" -taskList $TaskList -Verbose:$VerbosePreference
$thisTimer.Stop()

$elapsedTimeMsg = "`n`nSpent {0,4} mS performing operations.`n`n" -f $thisTimer.ElapsedMilliseconds
Write-Host $elapsedTimeMsg

Pop-Location
