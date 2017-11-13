<#
.SYNOPSIS
    Imports environment variables for the specified version of Visual Studio.
.DESCRIPTION
    Imports environment variables for the specified version of Visual Studio.
    This function requires the PowerShell Community Extensions. To find out
    the most recent set of Visual Studio environment variables imported use
    the cmdlet Get-EnvironmentBlock.  If you want to revert back to a previous
    Visul Studio environment variable configuration use the cmdlet
	Pop-EnvironmentBlock.
	
	This function was lifted directly from PSCX Copyright (c) 2015 Pscx
.PARAMETER VisualStudioVersion
    The version of Visual Studio to import environment variables for. Valid
    values are the common name for the Visual Studo Version (i.e. 2008, 2010, 
	2012, 2013, 2015 and 2017) or the Visual Studio Version itself (i.e. 90,
	100, 110, 120, 140, 150).
.PARAMETER Architecture
    Selects the desired architecture to configure the environment for.
    Defaults to x86 if running in 32-bit PowerShell, otherwise defaults to
    amd64.  Other valid values are: arm, x86_arm, x86_amd64, amd64_x86.
.EXAMPLE
    C:\PS> Import-VSVars 2015

    Sets up the environment variables to use the VS 2015 compilers. Defaults
    to x86 if running in 32-bit PowerShell, otherwise defaults to amd64.
.EXAMPLE
    C:\PS> Import-VSVars 2013 arm

    Sets up the environment variables for the VS 2013 ARM compiler.
.EXAMPLE
    C:\PS> Import-VSVars 150

    Sets up the environment variables to use the VS Version 15 (which is
	Visual Studio 2017) compilers. Defaults to x86 if running in 32-bit 
	PowerShell, otherwise defaults to amd64.
#>
[CmdletBinding()]
param
(
    [Parameter(Position = 0)]
    [ValidateSet('90', '2008', '100', '2010', '110', '2012', '120', '2013', '140', '2015', '150', '2017')]
    [string] $VisualStudioVersion,
    [Parameter(Position = 1)]
    [string] $Architecture
)

begin {
    $ArchSpecified = $true
    if (!$Architecture) {
        $ArchSpecified = $false
        $Architecture = $(if ($Pscx:Is64BitProcess) {'amd64'} else {'x86'})
    }

    function FindAndLoadBatchFile($ComnTools, $ArchSpecified, [switch]$IsAppxInstall) {
        if (!$ArchSpecified) {
            $batchFilePath = Convert-Path (Join-Path $ComnTools VsDevCmd.bat)
            Write-Verbose "Invoking '$batchFilePath'"
            Invoke-BatchFile $batchFilePath
        } else {
            if ($IsAppxInstall) {
                $batchFilePath = Convert-Path (Join-Path $ComnTools ..\..\VC\Auxiliary\Build\vcvarsall.bat)
            } else {
                $batchFilePath = Convert-Path (Join-Path $ComnTools ..\..\VC\vcvarsall.bat)
            }
            Write-Verbose "Invoking '$batchFilePath' $Architecture"
            Invoke-BatchFile $batchFilePath $Architecture
        }
    }
}

end {
    switch -regex ($VisualStudioVersion) {
        '90|2008' {
            #Push-EnvironmentBlock -Description "Before importing VS 2008 $Architecture environment variables"
            Write-Verbose "Invoking ${env:VS90COMNTOOLS}..\..\VC\vcvarsall.bat $Architecture"
            Invoke-BatchFile "${env:VS90COMNTOOLS}..\..\VC\vcvarsall.bat" $Architecture
        }

        '100|2010' {
            #Push-EnvironmentBlock -Description "Before importing VS 2010 $Architecture environment variables"
            Write-Verbose "Invoking ${env:VS100COMNTOOLS}..\..\VC\vcvarsall.bat $Architecture"
            Invoke-BatchFile "${env:VS100COMNTOOLS}..\..\VC\vcvarsall.bat" $Architecture
        }

        '110|2012' {
            #Push-EnvironmentBlock -Description "Before importing VS 2012 $Architecture environment variables"
            FindAndLoadBatchFile $env:VS110COMNTOOLS $ArchSpecified
        }

        '120|2013' {
            #Push-EnvironmentBlock -Description "Before importing VS 2013 $Architecture environment variables"
            FindAndLoadBatchFile $env:VS120COMNTOOLS $ArchSpecified
        }

        '140|2015' {
            #Push-EnvironmentBlock -Description "Before importing VS 2015 $Architecture environment variables"
            FindAndLoadBatchFile $env:VS140COMNTOOLS $ArchSpecified
        }

        '150|2017' {
            if ((Get-Module -Name VSSetup -ListAvailable) -eq $null) {
                Write-Warning "You must install the VSSetup module to import Visual Studio variables for this version of Visual Studio."
                Write-Warning "Install this PowerShell module with the command: Install-Module VSSetup -Scope CurrentUser"
                throw "VSSetup module not installed, unable to import Visual Studio environment variables."
            }
            Import-Module VSSetup -ErrorAction Stop
            $installPath = Get-VSSetupInstance | 
                Select-VSSetupInstance -Version '[15.0,16.0)' -Require Microsoft.VisualStudio.Component.VC.Tools.x86.x64 | 
                Select-Object -First 1 | ForEach-Object InstallationPath
            #Push-EnvironmentBlock -Description "Before importing VS 2017 $Architecture environment variables"
            FindAndLoadBatchFile "$installPath/Common7/Tools" $ArchSpecified -IsAppxInstall
        }

        default {
            $envvar = Get-Item Env:\vs*comntools
            if ($envvar) {
                $ver = ''
                if ($envvar.Name -match 'vs(.*?)comntools') {
                    $ver = $matches[1]
                }

                #Push-EnvironmentBlock -Description "Before importing $ver $Architecture environment variables"

                $vscomntoolspath = $envvar.Value
                $vcvarsallPath = Join-Path $vscomntoolspath "..\..\VC\vcvarsall.bat"
                Write-Verbose "Invoking default path $vcvarsallPath $Architecture"
                Invoke-BatchFile $vcvarsallPath $Architecture
            }
        }
    }
}

