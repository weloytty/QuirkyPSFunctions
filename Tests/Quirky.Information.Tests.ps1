Import-Module Quirky -Force


Describe "Unit Testing Quirky Information:" {
    InModuleScope Quirky {
        Context "Aliases" {
            $returnValue = (Get-Alias shares).Definition
            It "Should know what the 'shares' alias does" {
                $returnValue | Should Be "Get-ComputerShares"
            }
            $aliasValue = (Get-Alias cal -ErrorAction SilentlyContinue).Definition
            It "Should know what the 'cal' Alias does" {
                $aliasValue | Should Be "Show-Calendar"
            }

        }

        Context Quirky\Get-PowershellVersion {

            $returnValue = Quirky\Get-PowershellVersion -ComputerName . -Quiet

            It 'Knows what version of powershell this computer has' {
                $returnValue.PSVersion.ToString() | Should Be $($PSversionTable.PSVersion.ToString())
            }
        } #Context Quirky\Get-PowershellVersion {


        Context Quirky\Show-Calendar {

            $returnValue = $(Get-Command Quirky\Show-Calendar|select-object -expand Name )

            It 'Can find Show-Calendar' {
                $returnValue.Length | Should Be $true
            }
        } #Context Quirky\Get-PowershellVersion {

    } #InModuleScope Quirky{
} #Describe "Unit Testing Quirky Information:" {
