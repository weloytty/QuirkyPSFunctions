Import-Module Quirky -Force


Describe "Unit Testing Quirky Utilities:" {
  InModuleScope Quirky {

    Context "Aliases" {
      $aliasValue = (Get-Alias edc -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'edc' Alias does" {
        $aliasValue | Should Be "Edit-Command"
      }

      $aliasValue = (Get-Alias fi -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'fi' Alias does" {
        $aliasValue | Should Be "Find-Items"
      }
      $aliasValue = (Get-Alias gev -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'gev' Alias does" {
        $aliasValue | Should Be "Get-EnvironmentVariable"
      }
      $aliasValue = (Get-Alias ief -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'ief' Alias does" {
        $aliasValue | Should Be "Set-IEFriendlyErrors"
      }
      $aliasValue = (Get-Alias howlonguntilchristmas -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'howlonguntilchristmas' Alias does" {
        $aliasValue | Should Be "Get-DaysUntilChristmas"
      }
      $aliasValue = (Get-Alias killps -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'killps' Alias does" {
        $aliasValue | Should Be "Stop-OtherPowerShell"
      }
      $aliasValue = (Get-Alias gurl -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'gurl' Alias does" {
        $aliasValue | Should Be "Get-ExpandedURL"
      }

      $aliasValue = (Get-Alias sdp -ErrorAction SilentlyContinue).Definition
      It "Should know what the 'sdp' Alias does" {
        $aliasValue | Should Be "Start-DebugPowerShell"
      }





    }

    Context "Quirky\Get-ExpandedURL" {
      It "Can expand URLS" {
        $expectedResult = 'http://time.com/4482179/sen-rand-paul-epipen-scandal/?xid=tcoshare'
        $inputURL = 'https://t.co/TcB9pOuGWB'

        Get-ExpandedURL -inputURLs $inputURL
        Quirky\Get-ExpandedURL -inputURLs $inputURL | Should Be $expectedResult
      }
    }

    Context "Quirky\Test-Win64" {
      if ((Get-WmiObject win32_operatingsystem).OSArchitecture -notlike '64-bit') {

        It "Knows that it's not running on a 64 bit machine" {
          Quirky\Test-Win64 | Should Be $false
        }

      } else {
        It "Knows that it's running on a 64 bit machine" {
          Quirky\Test-Win64 | Should Be $true
        }
      }

    }

    Context "Quirky\Test-Win32" {
      if ((Get-WmiObject win32_operatingsystem).OSArchitecture -notlike '64-bit') {
        It "Knows that it's running on a 32 bit machine" {
          Quirky\Test-Win32 | Should Be $true
        }

      } else {
        It "Knows that it's not running on a 32 bit machine" {
          Quirky\Test-Win32 | Should Be $false
        }
      }
    }

    Context "Quirky\Get-DaysUntilChristmas" {
      Mock Get-Date { return New-Object DateTime (2016,7,4) }

      $return = Quirky\Get-DaysUntilChristmas -Date $(Get-Date) -WhatYear 2016
      It "Counts Properly from July 4, 2016" {
        $return.NumberOfDays | Should Be 174
      }
    }
    Context "Quirky\Get-NumberOfDays" {
      $return = Get-NumberOfDays 1/1/2000 1/1/2015

      It "Knows the number of days between 1/1/2000 and 1/1/2015" {
        $return.NumberOfDays | Should Be 5479
      }

      $return = Get-NumberOfDays 1/1/2015 1/1/2000
      It "Even knows them backwards" {
        $return.NumberOfDays | Should Be -5479
      }

      $return = Get-NumberOfDays 1/1/2500 1/1/2900
      It "Knows the difference between 1/1/2500 and 1/1/2900" {
        $return.NumberOfDays | Should Be 146097
      }



    }

    Context "Quirky\IsNumeric" {
      $return = 23049234 | Quirky\IsNumeric
      It "Knows what numbers are like" {
        $return | Should Be $true
      }

      $return = "alsdfjk" | Quirky\IsNumeric
      It "Knows what a string looks like" {
        $return | Should Be $false
      }

      $return = 1.23442 | Quirky\IsNumeric
      It "Knows what a decimal point is" {
        $return | Should Be $true
      }
    }


  }

}
