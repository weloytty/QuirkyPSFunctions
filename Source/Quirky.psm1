#Requires -Version  3


Set-StrictMode -Version Latest

function WriteUsage ([string]$msg) {

    Write-Host @"

To load all  modules using the default preferences execute:

    Import-Module Quirky

To load all Quirky modules except a few, pass in a hashtable containing
a nested hashtable called ModulesToImport.  In this nested hashtable
add the module name you want to suppress and set its value to false e.g.:

    Import-Module PersonalFunctions -args @{ModulesToImport = @{DirectoryServices = $false}}

To have complete control over which  modules load as well as
normal options, copy the Quirky.Preferences.ps1 file to your home dir. Edit this
file and modify the settings as desired.  Then pass the path to this file as
an argument to Import-Module as shown below:

    Import-Module Quirky -arg ~\Quirky.Preferences.ps1

"@
}
$PreferencesFile = "Quirky.Preferences.ps1"
$modulesToLoad = @()
$defaultPreferences = $(Join-Path $PSScriptRoot $PreferencesFile)
$userPreferences = ''



if ((Test-Path Variable:\PROFILE) -and ($PROFILE -ne '')) {

    $userPreferences = $(Join-Path $(Split-Path $PROFILE -Parent) $PreferencesFile)
}
$usedPreferences = $defaultPreferences


if ($userPreferences -ne '' -and (Test-Path ($userPreferences))) {
    $usedPreferences = $userPreferences
}


if ($args.Length -gt 0) {
    if (Test-Path $args[0]) {
        Write-Verbose "Using preferences from $($args[0])"
        $usedPreferences = $args[0]
    }
}

$Global:QuirkyPreferences = & $usedPreferences

$timeIt = $Global:QuirkyPreferences.Get_Item("ShowModuleLoadInfo")
$debugSpew = $Global:QuirkyPreferences.Get_Item("ShowStartupDebugSpew")


if ($debugSpew) {
    Write-Host "`nQuirky loading"
    Write-Host "Path: $PSScriptRoot`n"
    Write-Host "Preferences file:`n$usedPreferences"
    Write-Host "Editor Command is $($Global:QuirkyPreferences.Get_Item("EditorCommand"))"
    Write-Host "Editor Arguments are $($Global:QuirkyPreferences.Get_Item("EditorArguments"))"
    Write-Host "Sysinternals Dir is $($Global:QuirkyPreferences.Get_Item("SysinternalsDir"))"
    Write-Host "`nShowing Load Times  :"
    Write-Host "        Modules     :    $timeIT"
    Write-Host "        Environment :    $timeIT`n"

}
$envTimer = New-Object System.Diagnostics.StopWatch
$envMilliseconds = 0
$envEditorMS = 0
$envArgsMS = 0
$totalEnvTime = ""
$totalElapsed = 0

$EditorCommand = $Global:QuirkyPreferences.Get_Item("EditorCommand")
if ($null -ne $EditorCommand ) {
    if ($debugSpew) {
        Write-Host "Setting environment variable `$Env:EditorCommand to $($EditorCommand)`n"
    }
    if ($timeIt) {

        $envTimer.Reset()
        $envTimer.Start()
    }
    $currentEditorCommand = $env:EditorCommand
    if ($currentEditorCommand -ne $EditorCommand) {
        [environment]::SetEnvironmentVariable("EditorCommand", $EditorCommand, "User")
    } else {
        if ($debugSpew) {
            Write-Host "Environment variable EditorCommand $EditorCommand already set."
        }
    }
    if ($timeIt) {
        $envTimer.Stop()
        $envEditorMS = $envTimer.ElapsedMilliseconds
        $totalElapsed += $envTimer.ElapsedMilliseconds
        $elapsedTimeMsg = "Spent {0,4} mS setting editor environment variable.`n" -f $envEditorMS
        $envMilliseconds += $envEditorMS
        if ($debugSpew) { Write-Host $elapsedTimeMsg; Write-Host "" }

    }

}

$EditorArgs = $Global:QuirkyPreferences.Get_Item("EditorArguments")
if ($null -ne $EditorArgs ) {
    if ($debugSpew) {
        Write-Host "Setting environment variable `$Env:EditorArguments to $($EditorArgs)"
    }

    if ($timeIt) {

        $envTimer.Reset()
        $envTimer.Start()
    }

    $argsVar = $env:EditorArguments
    if ($argsVar -ne $EditorArgs) {
        [environment]::SetEnvironmentVariable("EditorArguments", $EditorArgs, "User")
    } else {
        if ($DebugSpew) {
            Write-Host "Environment variable EditorArgs $EditorArgs already set"
        }
    }
    if ($timeIt) {
        $envTimer.Stop()
        $elapsedTimeMsg = "Spent {0,4} mS setting editor environment variables.`n" -f $envTimer.ElapsedMilliseconds
        $envMilliseconds += $envTimer.ElapsedMilliseconds
        $totalElapsed += $envMilliseconds
        $totalEnvTime = "{0,4}" -f $envMilliseconds
        if ($debugSpew) {
            Write-Host $elapsedTimeMsg; Write-Host ""


        }

    }
    $envTimer = $null
} else {if ($debugSpew) {Write-Host "No EditorArguments set.`n"}}



foreach ($key in $Global:QuirkyPreferences.Keys) {

    if ($key -eq "ModulesToImport") {
        foreach ($modKey in $Global:QuirkyPreferences.ModulesToImport.Keys) {
            $modKeyValue = $($Global:QuirkyPreferences.ModulesToImport[$modKey])

            if ($debugSpew) { Write-Host "Module $($modKey.padRight(33)) will load:    " -NoNewline }
            $color = 'Red'
            if ($modKeyValue) { $Color = 'Green' }
            if ($debugSpew) { Write-Host "$modKeyValue" -ForegroundColor $Color }
            if ($Global:QuirkyPreferences.ModulesToImport[$modKey] -eq $true) {

                $modulesToLoad += $modKey
            }

        }
        if ($DebugSpew) { Write-Host "`n" }
    }
}



$totalModuleLoadTimeMs = 0
$stopWatch = New-Object System.Diagnostics.StopWatch
foreach ($modName in $modulesToLoad) {
    if ($TimeIt) {
        $stopWatch.Reset()
        $stopWatch.Start()
    }

    $moduleToLoad = "$PSScriptRoot\{0}\Quirky.{0}.psm1" -f $modName
    $info = $(Get-Item $moduleToLoad)
    if ($DebugSpew) {
        Write-Host "File: $(Split-Path $info.FullName -Leaf)" 
        Write-Host "Length: ($($info.Length) bytes) Date: $($info.LastWriteTime)"
        #Write-Host "Length: $($info.Length)"
        #Write-Host "Date  : $($info.LastWriteTime)`n"
    }
    Import-Module -Name $moduleToLoad -Verbose:$VerbosePreference
    if ($TimeIt) {
    
        $stopWatch.Stop()
        $totalModuleLoadTimeMs += $stopWatch.ElapsedMilliseconds

        $whatToWrite = $(Split-Path $info.FullName -Leaf)
        $loadTimeMsg = "$($whatToWrite.PadRight(40)) loaded in: {0,4} mS" -f $stopWatch.ElapsedMilliseconds
        Write-Host $loadTimeMsg`n

    }

}
$stopWatch = $null
if ($TimeIt) {
    $totalElapsed += $totalModuleLoadTimeMs
 
    $outputString = "Load time - Module      : {0,4} mS`n" -f $totalModuleLoadTimeMs 
    $outputString += "Load time - Environment : {0,4} mS`n" -f $envMilliseconds
    $outputString += "`n          Total         : {0,4} mS`n" -f $totalElapsed 
    Write-Host $outputString
}

Remove-Item Function:\WriteUsage
Export-ModuleMember -Alias * -Function * -Cmdlet *


