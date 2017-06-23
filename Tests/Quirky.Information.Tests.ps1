Import-Module Quirky -Force


Describe "Unit Testing Quirky Information:" {
  InModuleScope Quirky {
    Context "Aliases" {
      $returnValue = (Get-Alias shares).Definition
      It "Should know what the 'shares' alias does" {
        $returnValue | Should Be "Get-ComputerShares"
      }
    }

    Context Quirky\Get-PowershellVersion {

      $returnValue = Quirky\Get-PowershellVersion -ComputerName . -Quiet

      It 'Knows what version of powershell this computer has' {
        $returnValue.PSVersion.ToString() | Should Be $($PSversionTable.PSVersion.ToString())
      }
    } #Context Quirky\Get-PowershellVersion {
  } #InModuleScope Quirky{
} #Describe "Unit Testing Quirky Information:" {
