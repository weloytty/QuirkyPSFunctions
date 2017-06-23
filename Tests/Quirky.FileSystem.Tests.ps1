#
# Quirky.ps1
#
Import-Module Quirky -Force

Describe "Testing Aliases" {
  InModuleScope Quirky {
    Context "Aliases" {

      $aliasValue = (Get-Alias gcisize -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'gcisize' Alias does" {
        $aliasValue | Should Be "Get-ChildItemBySize"
      }

      $aliasValue = (Get-Alias gcidate -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'gcidate' Alias does" {
        $aliasValue | Should Be "Get-ChildItemByDate"
      }

      $aliasValue = (Get-Alias gcidirs -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'gcidirs' Alias does" {
        $aliasValue | Should Be "Get-ChildItemDirectories"
      }



      $aliasValue = (Get-Alias slf -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'slf' Alias does" {
        $aliasValue | Should Be "Set-LocationFromFile"
      }

      $aliasValue = (Get-Alias slp -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'slp' Alias does" {
        $aliasValue | Should Be "Set-LocationToProfileFolder"
      }

      $aliasValue = (Get-Alias home -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'home' Alias does" {
        $aliasValue | Should Be "Set-LocationToProfileFolder"
      }

    }
  }



}
