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
                if ($PSVersionTable.PSVersion.Major -gt 5 -and  $returnValue.PSVersion.Major -eq 5) {
                    $returnValue.PSVersion.Major|Should Be 5
                } else {
                    $returnValue.PSVersion.ToString() | Should Be $($PSversionTable.PSVersion.ToString())
                }
             
            }
        } #Context Quirky\Get-PowershellVersion {


        Context Quirky\Show-Calendar {

            $returnValue = $(Get-Command Quirky\Show-Calendar|select-object -expand Name )

            It 'Can find Show-Calendar' {
                $returnValue.Length | Should Be $true
            }
        } #Context Quirky\Get-PowershellVersion {

        Context Quirky\Test-PwnedPassword {
            $returnValue = $(Get-Command Quirky\Test-PwnedPassword|Select-Object -expand Name)
            It 'Can find Test-PwnedPassword' {
                $returnValue.Length |Should Be $true
            }

            $returnNumber = $(Quirky\Test-PwnedPassword -Quiet -PwdToTest 'Booger')
            It 'Knows how many times Booger has been used' {
                $returnNumber|Should -BeGreaterOrEqual 1076 
            }

        }

    } #InModuleScope Quirky{
} #Describe "Unit Testing Quirky Information:" {
