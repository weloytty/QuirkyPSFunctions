
  [CmdletBinding()]
  param([switch]$Detailed)

  begin
  {
    $returnValue = ""

    
  }
  process
  {
    $userName = $env:USERNAME
    $userDomain = $env:UserDomain

    $returnValue = "$userDomain\$userName"
    if ($detailed)
    {
      $objUser = [adsi]"WinNT://$userDomain/$userName,user"

      #$members = $objUser | Get-Member
      if ($VerbosePreference)
      {

        foreach ($member in $objUser.PSObject.Properties)
        {
          $name = $member.Name
          Write-Verbose "$($member.Name):$($objUser."$name")"
        }
      }

      $returnValue = $objUser

    }

  }
  end
  {
    $returnValue
  }


