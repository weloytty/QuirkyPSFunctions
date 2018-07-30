
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
      $results = ($thisComputer.psbase.Children | Where-Object { $_.psbase.schemaclassname -eq 'user' } | Select-Object Name,Description,LastLogin)

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

