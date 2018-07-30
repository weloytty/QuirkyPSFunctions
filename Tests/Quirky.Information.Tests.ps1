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

            $aliasValue = (Get-Alias hex2dec -ErrorAction SilentlyContinue).Definition
            It "Should know what the 'hex2dec' Alias does exist" {
                $aliasValue | Should Be "Convert-HexToDec"
            }

            $aliasValue = (Get-Alias dec2hex -ErrorAction SilentlyContinue).Definition
            It "Should know what the 'dec2hex' Alias does exist" {
                $aliasValue | Should Be "Convert-DecToHex"
            }


        }

        Context Quirky\Get-PowershellVersion {

            $returnValue = Quirky\Get-PowershellVersion -ComputerName . -Quiet

            It 'Knows what version of powershell this computer has' {
                if ($PSVersionTable.PSVersion.Major -gt 5 -and $returnValue.PSVersion.Major -eq 5) {
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

        Context Quirky\Convert-HexToDec {
            $returnValue = $(Get-Command Quirky\Convert-HexToDec|Select-Object -expand Name)
            It 'Can find Convert-HexToDec' {
                $returnValue.Length |Should -BeGreaterOrEqual 1
            }

            $returnNumber = Quirky\Convert-HexToDec -InputNumber ABC
            It 'Can convert ABC to 2748' {
                $returnNumber|Should -BeExactly 2748
            }

            $returnNada = Quirky\Convert-HexToDec -InputNumber asldkfjsalkfjdasklasjdf
            It 'Can figure out nonsense' {
                $returnNada|Should -BeNullOrEmpty
            }

            $returnLooksLikeDec = Quirky\Convert-HexToDec -InputNumber 456
            It 'Knows that 0x456 is 1110' {
                $returnLooksLikeDec|Should -BeExactly 1110
            }

        }
        Context Quirky\Convert-DecToHex {
            $returnValue = $(Get-Command Quirky\Convert-DecToHex|Select-Object -expand Name)
            It 'Can find Convert-DecToHex' {
                $returnValue.Length|Should -BeGreaterOrEqual 1
            }
            $retNum = Quirky\Convert-DecToHex -InputNumber 1110
            It 'Knows 1110 is 0x456' {
                $retNum|Should -BeExactly 456
            }
        }

    } #InModuleScope Quirky{
} #Describe "Unit Testing Quirky Information:" {
