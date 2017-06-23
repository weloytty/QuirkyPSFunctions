#
# Quirky.psm1
#

function Test-IsAdmin {
  [CmdletBinding()]
  param()

  return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")

}
Set-Alias IsAdmin -Value Test-IsAdmin


function Get-QLocalGroupMember ()
{
  [CmdletBinding()]
  param(
    [Parameter(ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true,Mandatory = $true)]
    [Alias("FQDN")]
    [string[]]$ComputerName,
    [Parameter(Mandatory = $true)]
    [string]$LocalGroupName,
    [switch]$DisplayOnly,
    [switch]$Quiet
  )

  begin
  {
    Set-StrictMode -Version Latest

    if ($Quiet -and (-not $DisplayOnly)) { Write-Verbose "Quiet with DisplayOnly set. No output will be produced" }
    $returnObject = @()
  }

  process
  {
    foreach ($computer in $ComputerName) {
      Write-Verbose "Testing if $computer is up"
      if (Test-Connection $computer) {

        if ($computerName -eq "") { $computerName = "$env:computername" }

        Write-Verbose "Checking if group $localGroupName exists"
        if ([adsi]::Exists("WinNT://$computer/$localGroupName,group")) {

          Write-Verbose "Getting $localGroupName"
          $group = [adsi]("WinNT://$computer/$localGroupName,group")


          $results = @()
          $members = @( $group.psbase.Invoke("Members"))
          Write-Verbose "Processing Group Members"

          if (-not $Quiet)
          {
            $output = "Members of group $LocalGroupname on Computer $computer"

            Write-Host $output
            Write-Host $("-" * $output.Length)
          }

          foreach ($m in $members)
          {

            [hashtable]$thisMember = @{}


            $thisMember.ComputerName = $computer
            $thisMember.Group = $LocalGroupName
            $thisMember.Name = $m.GetType.Invoke().InvokeMember("Name",'GetProperty',$null,$m,$null)
            $thisMember.Class = $m.GetType.Invoke().InvokeMember("Class",'GetProperty',$null,$m,$null)
            $thisMember.Path = $m.GetType.Invoke().InvokeMember("ADsPath",'GetProperty',$null,$m,$null)

            $thisMember.Type = 'Domain'
            if (($thisMember.Path -like "*/$computer/*"))
            {
              $thisMember.Type = 'Local'
            }

            # Check if this member is a group.
            $isGroup = ($m.GetType.Invoke().InvokeMember("Class",'GetProperty',$Null,$m,$Null) -eq "group")
            if ($isGroup)
            {
              #do this later
            }

            if (-not $Quiet)
            {
              $accountType = $thisMember.Class.padRight(8)
              $name = $thisMember.Name.padRight(15)

              Write-Host "Account Type: $accountType Name: $name "
              Write-Host ""
            }


            $results += New-Object -Type PSObject -Property $thisMember

          }
          $returnObject += $results

        }
        else {
          Write-Verbose "Local group '$localGroupName' doesn't exist on computer '$computerName'"
        }
      }


    }

  }

  end
  {

    if ($DisplayOnly) { $returnObject = $null }

    return $returnObject
  }
}



function Add-QDomainUserToLocalGroup
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true,ValueFromPipeline = $true)]
    [string[]]$ComputerName,
    [string]$UserDomain,
    [Parameter(Mandatory = $true)]
    [string]$UserName,
    [Parameter(Mandatory = $true)]
    [string]$LocalGroupName
  )

  begin
  {
    Set-StrictMode -Version Latest

    if ($UserDomain -eq $null) { $UserDomain = ([adsi]'').Name }
  }
  process
  {
    foreach ($computer in $computername)
    {
      if (Test-Connection -ComputerName $computer -Quiet)
      {
        ([adsi]"WinNT://$computerName/$localGroupName,group").Add("WinNT://$UserDomain/$UserName")
      } else { Write-Output "Can't connect to computer $computerName" }



    }
  }
  end
  {

  }
}

function New-QLocalUser
{
  [CmdletBinding()]
  param(
    [string]$ComputerName = $($Env:COMPUTERNAME),
    [Parameter(Mandatory = $true)]
    [string]$UserName,
    [Parameter(Mandatory = $true)]
    [string]$Password,
    [string]$Description)

  begin
  {
    Set-StrictMode -Version Latest
  }
  process
  {
    if ($Description -eq $null) { $description = "" }
    $objOu = [adsi]"WinNT://$ComputerName,Computer"
    $objUser = $objOU.Create("User",$UserName)
    $objUser.setpassword($password)
    $objUser.SetInfo()
    $objUser.description = $Description
    $objUser.SetInfo()
  }
  end {}

}

function Get-QLocalUser ()
{
  [CmdletBinding()]
  param(
    [Parameter(ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
    [string]$ComputerName = $($env:COMPUTERNAME),
    [Parameter(Mandatory = $true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
    [string[]]$Name
  )

  begin
  {
    Set-StrictMode -Version Latest
    $returnArray = @()
  }
  process
  {
    # List all local users on the local or a remote computer


    foreach ($user in $Name)
    {
      if ($ComputerName -eq '.') { $computername = $env:COMPUTERNAME }
      #Name                        Property   System.DirectoryServices.PropertyValueCollection
      $thisComputer = [adsi]"WinNT://$computerName,computer"
      $results = ($thisComputer.psbase.Children | Where-Object { $_.psbase.schemaclassname -eq 'user' -and $_.Name -match "$user" } | select Name,Description,LastLogin)

      foreach ($returneduser in $results) {

        [hashtable]$thisUser = @{}
        $thisUser.UserName = $returneduser | select -ExpandProperty Name
        $thisUser.description = $returneduser | select -ExpandProperty Description
        $thisUser.LastLogin = $returneduser | select -ExpandProperty LastLogin

        $returnArray += (New-Object -Type PSObject -Property $thisUser)

      }
    }
  }
  end
  {
    return $returnArray
  }
}

function Get-CurrentUser ()
{
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

      $members = $objUser | Get-Member
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
    return $returnValue
  }

}



function Get-QLocalUsers ()
{
  [CmdletBinding()]
  param(
    [Parameter(ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
    [string[]]$ComputerName = $($Env:COMPUTERNAME))

  begin
  {
    Set-StrictMode -Version Latest
    $returnArray = @()
  }
  process
  {
    # List all local users on the local or a remote computer


    foreach ($computer in $ComputerName)
    {
      if ($computer -eq '.') { $computer = $Env:COMPUTERNAME }
      #Name                        Property   System.DirectoryServices.PropertyValueCollection
      $thisComputer = [adsi]"WinNT://$computer,computer"
      $results = ($thisComputer.psbase.Children | Where-Object { $_.psbase.schemaclassname -eq 'user' } | select Name,Description,LastLogin)

      foreach ($returneduser in $results) {

        [hashtable]$thisUser = @{}
        $thisUser.UserName = $returneduser | Select-Object -ExpandProperty Name
        $thisUser.description = $returneduser | Select-Object -ExpandProperty Description

        $thisUser.LastLogin = $returneduser | Select-Object -ExpandProperty LastLogin

        $returnArray += (New-Object -Type PSObject -Property $thisUser)

      }
    }
  }
  end
  {
    return $returnArray
  }
}
