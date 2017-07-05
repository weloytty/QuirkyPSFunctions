[CmdletBinding()]
param([System.Management.Automation.PSModuleInfo[]]$Module,
    [string]$ModuleName)

begin {

    Set-StrictMode -Version Latest
    
    if ($Module -eq $null) {
        $Module = Get-Module -Name $ModuleName -All
    }
    $thisModule = $Module
}

process {
    Write-Verbose "There are $($thisModule.Count) versions of $($thisModule[0].Name)"
    if ($VerbosePreference) {
        for ($i = 0; $i -lt $thisModule.Count; $i++) {
            Write-Verbose "$($thisModule[$i].Version)"
        }
    }

    $returnValue = $thisModule
    if ($thisModule.Count -gt 1) {
        $savedMajor = 0
        $savedMinor = 0
        $savedBuild = 0
        $savedRevision = 0
        for ($thisIndex = 0; $thisIndex -lt $thisModule.Count; $thisIndex++) {
            if ($thisModule[$thisIndex].Version.Major -gt $savedMajor) {
                $savedMajor = $thisModule[$thisIndex].Version.Major
                $highestIndex = $thisIndex
            }
            if ($highestIndex -ne $thisIndex) {
                if ($thisModule[$thisIndex].Version.Minor -gt $savedMinor) {
                    $savedMinor = $thisModule[$thisIndex].Version.Minor
                    $highestIndex = $thisIndex
                }

            }

            if ($highestIndex -ne $thisIndex) {
                if ($thisModule[$thisIndex].Version.Build -gt $savedBuild) {
                    $savedBuild = $thisModule[$thisIndex].Version.Build
                    $highestIndex = $thisIndex
                }

            }

            if ($highestIndex -ne $thisIndex) {
                if ($thisModule[$thisIndex].Version.Revision -gt $savedRevision) {
                    $savedRevision = $thisModule[$thisIndex].Version.Revision
                    $highestIndex = $thisIndex
                }

            }
        } #for($thisIndex = 0;$thisIndex -lt $thisModule.Count;$thisIndex++)
        $returnValue = $thisModule[$highestIndex]
    } #if($thisModule.Count -gt 1){
}
end {
    Write-Verbose "Returning highest version, version $($returnValue.Version)"
    return $returnValue
}