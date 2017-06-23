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


    Context "Quirky\Get-QLocalUser" {
      $results = Get-QLocalUser -ComputerName . -Name Administrator

      It "Can see if there is an Administrator" {
        $results | gm
        $results.UserName | Should Be "Administrator"
      }
    }

    Context "Quirky\Test-IsAdmin" {
      $results = Test-IsAdmin
      $expectedResult = $true

      #on win7 if you're an admin, this will return true.  On win10 (and 8?)
      #you wont show as admin unless you're elevated
      if ([System.Environment]::OSVersion.Version.Build -gt 7601) { $expectedResult = $false }


      It "Should if I'm an admin on this computer" {
        $results | Should Be $expectedResult
      }
    }
  }
}

