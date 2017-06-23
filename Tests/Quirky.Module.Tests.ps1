#
# Quirky.ps1
#

Import-Module Quirky -Force

Describe "Testing Aliases for Module" {
  InModuleScope Quirky {
    Context "Aliases" {
	 $aliasValue = (Get-Alias slm -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'slm' Alias does" {
        $aliasValue | Should Be "Set-LocationToModuleFolder"
      }
	        $aliasValue = (Get-Alias gms -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'gms' Alias does" {
        $aliasValue | Should Be "Find-CommandSourceCode"
      }
	}
	}
	}