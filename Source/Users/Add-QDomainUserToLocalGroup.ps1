
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

    if ($null -eq $UserDomain ){ $UserDomain = ([adsi]'').Name }
  }
  process
  {
    foreach ($computer in $computername)
    {
      if (Test-NetConnection -ComputerName $computer -InformationLevel Quiet)
      {
        ([adsi]"WinNT://$computerName/$localGroupName,group").Add("WinNT://$UserDomain/$UserName")
      } else { Write-Output "Can't connect to computer $computerName" }



    }
  }
  end
  {

  }

