[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false, Position = 0)]
    [String]$ComputerName = $Env:COMPUTERNAME,
    [Parameter(Mandatory = $false, Position = 1)]
    [System.Management.Automation.PsCredential]$Credential,
    [Parameter(Mandatory = $false, Position = 2)]
    [Datetime]$Before,
    [Parameter(Mandatory = $false, Position = 3)]
    [Datetime]$After
)
Try {
    $result = @()
    If ($Credential) {
        $LogOnEvents = Get-WinEvent -ComputerName $ComputerName -Credential $Credential -filterHashtable @{LogName = 'Security'; Id = 4624; Level = 0}  |  Where-Object { $_.Properties[8].Value -eq 10}
    } Else {
        $LogOnEvents = Get-WinEvent -filterHashtable @{LogName = 'Security'; Id = 4624; Level = 0}  |  Where-Object { $_.Properties[8].Value -eq 10}
    }
    If ($LogOnEvents) {
        Foreach ($Event in $LogOnEvents ) {
            $UserName = $Event.Properties[5].value 
            $Ip = $Event.Properties[18].value
            $logObj = New-Object PSobject -Property @{ComputerName = $ComputerName; Time = $Event.TimeCreated; UserName = $UserName ; ClientIPAddress = $Ip  }  
            $result = $result + $logObj 
        }
        if ($Before -and $After) {
            $result | Where-Object { ($_.Time -le $Before) -and ($_.Time -ge $After) }
        } Else {
            If ($Before) {
                $result | Where-Object {$_.Time -le $Before}
            } Elseif ($After) {
                $result | Where-Object {$_.Time -ge $After}
            } Else {
                $result
            }
        }
			
    }
} Catch {
    Write-Error $_
}

<#
 	.SYNOPSIS
        Get-OSCRDPIPaddress is an advanced function which can be list RDP IP address.
		
    .DESCRIPTION
        Get-OSCRDPIPaddress is an advanced function which can be list RDP IP address.
		
	.PARAMETER	<ComputerName <string[]>
		Specifies the computers on which the command runs. The default is the local computer. 
		
	.PARAMETER  <Credential>
		Specifies a user account that has permission to perform this action. 
	.PARAMETER  <Before>
		lists records before the specified day.
	.PARAMETER  <After>
		lists records after the specified day.
		
    .EXAMPLE
        C:\PS> Get-OSCRDPIPaddress  -before 4/2/2013
		
		This command lists all RDP IP address records before 4/2/2013 in local machine.
		
    .EXAMPLE
		C:\PS> $cre = Get-Credential
        C:\PS> Get-OSCFolderPermission -ComputerName "abcd0123" -Credential $cre -After 4/2/2013
		
		This command lists all RDP IP address records after 4/2/2013 in computer "abcd0123"
#>