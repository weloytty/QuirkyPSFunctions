#
# Quirky.ps1
#
Import-Module Quirky -Force

$ManifestPath = "$(Split-Path $PSScriptRoot -Parent)\Source\Quirky.psd1"

Describe "Module Manifest Tests" {
    It 'Passes Test-Path' {
        Test-Path -Path $ManifestPath 
        $?|Should Be $true
    }

    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ManifestPath
        $?|Should Be $true
    }
}


Describe "Unit Testing Quirky Base Module:" -Tags @( "runfirst") {
    InModuleScope Quirky {

        $QuirkyModule = $(Get-Module -Name Quirky -ListAvailable)

        Assert ($QuirkyModule -ne $null) -failureMessage "Can't load Module"
        $QuirkyVersion = $($QuirkyModule).Version
        $VersionString = "$($QuirkyVersion.Major).$($QuirkyVersion.Minor).$($QuirkyVersion.Build).$($QuirkyVersion.Revision)"

        $QuirkyFolder = Get-Item ($QuirkyModule).ModuleBase | select -ExpandProperty Name



        It "Knows to be in a subdirectory matching its version" {
            Assert ($QuirkyFolder -eq $VersionString) -failureMessage "Folder name $QuirkyFolder doesn't match version of module $VersionString"
        }



    }
}
