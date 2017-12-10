[CmdletBinding()]
param([switch]$Force)

process {

    #https://www.reddit.com/r/PowerShell/comments/77s297/how_to_run_winr_shortcuts_in_powershell/
    $AppPaths = Get-ChildItem "HKLM:\\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths"


    $AppPaths | ForEach-Object {

        $Name = ($_.PSChildName -replace "\.exe", "")
        $Value = $_.name
        $Path = ((Get-ItemProperty ($value -replace "HKEY_LOCAL_MACHINE", "HKLM:\")).'(Default)')

        $existingAlias = $(Get-Alias -Name $Name -ErrorAction SilentlyContinue)
        if($existingAlias -and  $Force){
            Remove-Alias -Name $Name -Force
            $existingAlias = $false
         }
         Write-Verbose "Name: '$Name' Value: '$Path'"
        if ($Path -ne $null -and $Path.Length -gt 1) {
            if (-not $existingAlias) {Set-Alias -Name $Name -Value $Path}else {Write-Output "Skipping existing alias $Name"}
        } else {Write-Verbose "Skipping $Name, blank value"}
        

       
    }

}