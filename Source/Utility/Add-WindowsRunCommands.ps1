[CmdletBinding()]
param([switch]$Force)

begin {
    Set-StrictMode -vErsion Latest
}
process {
    $currError = $error
    #https://www.reddit.com/r/PowerShell/comments/77s297/how_to_run_winr_shortcuts_in_powershell/
    $AppPaths = Get-ChildItem "HKLM:\\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths"


    $AppPaths | ForEach-Object {

        $Name = ($_.PSChildName -replace "\.exe", "")
        $Value = $_.name

        $Path = $null
        $RegPath = Get-ItemProperty ($value -replace "HKEY_LOCAL_MACHINE", "HKLM:\")
   
        if ($null -eq ($RegPath.PSObject.Properties.name -match "'(Default)'")) {
            Write-Verbose "No default for $Name"
        }else{
            Write-Verbose "Getting .'(Default)'"
            try{
            $Path = $($RegPath).'(Default)'    
            }catch{
                Write-Verbose "Swallowing Exception for $Name"
                Write-Verbose "$RegPath"
            }
        }

        $existingAlias = $(Get-Alias -Name $Name -ErrorAction SilentlyContinue)
        if ($existingAlias -and $Force) {
            Remove-Alias -Name $Name -Force
            $existingAlias = $false
        }

        if ($null -ne $(Get-Command $Name -ErrorAction SilentlyContinue)) {
            $existingAlias = $true
            #if the command is already in the path, we don't need it.
            Write-Verbose "$Name is already a command, not readding"
        }
        Write-Verbose "Name: '$Name' Value: '$Path'"
        if ($Path -ne $null -and $Path.Length -gt 1) {
            if (-not $existingAlias) {Set-Alias -Name "$Name" -Value "$Path"}else {Write-Verbose "Skipping existing alias $Name"}
        } else {Write-Verbose "Skipping $Name, blank value"}
        

       
    }

    $error.Clear()
    $error = $currError

}