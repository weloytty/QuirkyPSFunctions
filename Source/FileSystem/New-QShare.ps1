<# 
     .Description 
          NAME:  
          AUTHOR: James Vierra , Designed Systems & Services 
          DATE  : 3/13/2009 
          COMMENT:  
                    09/15/2011 - Converted to PowerShell V2 
                    06/16/2014 - Add remote computer capability 
                    07/07/2017 - Lifted it and added it here
                                 Changed it around a little bit.
#> 
#requires -version 2.0 

[CmdLetBinding()] 
param( 
    [string]$Name, 
    [string]$Path, 
    [string]$ComputerName = $env:COMPUTERNAME, 
    [string]$Description = "", 
    [System.Security.Principal.NTAccount]$Account = "$($env:userdomain)\$($env:username)", 
    [ValidateSet('Read','FullControl')]
    [System.Security.AccessControl.FileSystemRights]$Rights = 'Read', 
    [int]$maxallowed = 16777216 
) 
 
function Create-WMITrustee([string]$NTAccount) { 
 
    $user = New-Object System.Security.Principal.NTAccount($NTAccount) 
    $strSID = $user.Translate([System.Security.Principal.SecurityIdentifier]) 
    $sid = New-Object security.principal.securityidentifier($strSID)  
    [byte[]]$ba = , 0 * $sid.BinaryLength      
    [void]$sid.GetBinaryForm($ba, 0)  
     
    $Trustee = ([WMIClass] "Win32_Trustee").CreateInstance()  
    $Trustee.SID = $ba 
    $Trustee 
     
} 
 
 
function Create-WMIAce { 
    param( 
        [string]$account, 
        [System.Security.AccessControl.FileSystemRights]$rights 
    ) 
    $trustee = Create-WMITrustee $account 
    $ace = ([WMIClass] "Win32_ace").CreateInstance()  
    $ace.AccessMask = $rights  
    $ace.AceFlags = 0 # set inheritances and propagation flags 
    $ace.AceType = 0 # set SystemAudit  
    $ace.Trustee = $trustee  
    $ace 
} 


if (Get-WmiObject -Class Win32_Share -Computername $ComputerName -filter "name='$name'") {
    Write-Output "Share $name already exists on $ComputerName"
} else {

    Write-Verbose "Using WMI to create a new Security Descriptor" 
    $sd = ([WMIClass] "Win32_SecurityDescriptor").CreateInstance() 
 
    Write-Verbose "Create new ACE" 
    $ace = Create-WMIAce $account $rights 
 
    Write-Verbose "Add Ace to DACL" 
    $sd.DACL += @($ace.psobject.baseobject) # append 
    $sd.ControlFlags = "0x4" # set SE_DACL_PRESENT flag  
 
    $share = [wmiclass]"\\$ComputerName\root\CimV2:Win32_Share" 
    Write-Verbose 'Calling WMI to Create share.' 
    $result = $share.Create( $path, $name, 0, $maxallowed, $description, $null, $sd ) 
    if ($result.returnValue -ne 0) { 
        Write-Host "Create share failed with returnValue=$($result.returnValue)" -ForegroundColor red -BackgroundColor white 
        return  
    } 
}