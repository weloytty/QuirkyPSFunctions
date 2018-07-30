
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
    if ($null -eq $Description) { $description = "" }
    $objOu = [adsi]"WinNT://$ComputerName,Computer"
    $objUser = $objOU.Create("User",$UserName)
    $objUser.setpassword($password)
    $objUser.SetInfo()
    $objUser.description = $Description
    $objUser.SetInfo()
  }
  end {}


