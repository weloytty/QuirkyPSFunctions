<#
	.SYNOPSIS
		Gets MSI Information from a MSI file
	.DESCRIPTION
		This function will open up a MSI file and get the property information that you want
	.PARAMETER FilePath
		Path to the MSI file
	.PARAMETER Property
		The Property that you want to get information from
	.EXAMPLE
		Get-MSIInformation -FilePath "mymsi.msi" -Property "ProductName"
	
		My MSI file
	
	.EXAMPLE
		Get-MSIInformation -FilePath "mymsi.msi" -Property "ProductVersion"
	
		1.0.0.0
	
	.EXAMPLE
		Get-MSIInformation -FilePath "mymsi.msi" -Property "ProductCode"
	
		{CFF8B5ED-0A4D-4EDD-9159-32FE1D31C9E3}
    .NOTES
    
    Original Author:
		Author: 	Fredrik Wall
		Email:		fredrik@poweradmin.se
        Created:	05/03/2014
        http://fredrikwall.se/deployment/msi-information-tool/
 
	

	
	#>
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]]$FileName,
    [String]$Property
)

begin {
    Set-StrictMode -Version Latest
    $returnValue = @()

    Write-Verbose "FileName : '$fileName'"
    Write-Verbose "Propertry: '$Property'"
    

    $queryString = "SELECT Value FROM Property Where Property = '$Property'"
    if ($Property -eq '') {
        $queryString = "Select * from Property"
    }
    Write-Verbose "Query    : '$queryString'"
}

process {
    foreach ($file in $FileName) {
        #try {
   
        $fileInfo = Get-Item $file
        $myWindowsInstaller = New-Object -com WindowsInstaller.Installer
        $myMSIDatabase = $myWindowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $Null, $myWindowsInstaller, @($fileInfo.FullName, 0))
 
        $myViews = $myMSIDatabase.GetType().InvokeMember("OpenView", "InvokeMethod", $Null, $myMSIDatabase, ($queryString))
        $msi_props = @{}
        foreach ($myView in $myViews) {
            $myView.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $myView, $Null)
 
            $myRecord = $myView.GetType().InvokeMember("Fetch", "InvokeMethod", $Null, $myView, $Null)
            if ($null -ne $myRecord) {
                #$thisMSIInfo = $myRecord.GetType().InvokeMember("StringData", "GetProperty", $Null, $myRecord, 1)
                
                while ($null -ne $myRecord) {
                    $prop_name = $myRecord.GetType().InvokeMember("StringData", "GetProperty", $Null, $myRecord, 1) 

                    Write-Verbose "prop_name='$prop_name'"


                    $prop_value = $myRecord.GetType().InvokeMember("StringData", "GetProperty", $Null, $myRecord, 2) 
                    Write-Verbose "prop_name='$prop_value'"
                    $msi_props[$prop_name] = $prop_value 

                    $myRecord = $myView.GetType().InvokeMember("Fetch", "InvokeMethod", $Null, $myView, $Null)
                }   
            }
        }
        $returnValue += $msi_props
        #} catch {
        #    throw "Failed to get MSI information. Error: {0}." -f $_
        #}
    }
}

end {
    $returnValue
}
