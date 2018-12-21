#
# Quirky.ps1
#
Import-Module Quirky -Force


Describe "Unit Testing Quirky User Functions:" {
  InModuleScope Quirky {

    Context "Aliases" {
      $aliasValue = (Get-Alias isadmin -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'isadmin' Alias does" {
        $aliasValue | Should Be "Test-IsAdmin"
      }
    }



    Context "Quirky\Test-IsAdmin" {
      $results = Test-IsAdmin
      
      #the build is the main consumer of these tests, and since
      #it copies to $env:ProgramFiles, it must be running as admin.
      
      $expectedResult = $true

      


      It "Should if I'm an admin on this computer" {
        $results | Should Be $expectedResult
      }
    }
  }
}

