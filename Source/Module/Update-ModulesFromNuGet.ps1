[CmdletBinding()]
param(
    [switch]$DisplayOnly,
    [switch]$NoUpdate,
    [switch]$AllAvailable,
    [switch]$Force
)

Set-StrictMode -Version Latest

$returnValues = @()
$modules = Get-Module -listavailable:$AllAvailable | Where-Object RepositorySourceLocation -Match 'https'

if ($modules -ne $null) {
    foreach ($module in $modules) {

        $updatedmodule = $(Find-Module $module.Name | Select-Object Name, Version, Repository, PackageManagementProvider)

        [hashtable]$moduleInfo = @{}
        $moduleInfo.Name = $module.Name
        $moduleInfo.LocalVersion = $module.Version
        $moduleInfo.RemoteVersion = $updatedmodule.Version
        $moduleInfo.Repository = $updatedmodule.Repository
        $moduleInfo.PackageManagementProvider = $updatedmodule.PackageManagementProvider

        $paddedModuleName = $($module.Name).padRight(28)

        if ($module.Version -eq $updatedmodule.Version) {
            Write-Host "$paddedModuleName version $($module.Version) is up to date."
        } else {
            $localColor = 'Green'
            $remotecolor = 'Green'
            $localversion = $module.Version
            $remoteVersion = $updatedmodule.Version

            if ($localVersion -ne $remoteVersion) {
                Write-Verbose "Local $localVersion Remote $remoteVersion"
                Write-Verbose $($remoteVersion -gt $localVersion)
                if ($remoteVersion -gt $localVersion) {
                    $needsUpdate = $true
                    $localColor = 'Red'
                } else {
                    $remoteColor = 'Red'
                }
            }

            Write-Host "$paddedModuleName local version " -NoNewline
            Write-Host "$localVersion" -ForegroundColor $localColor -NoNewline
            Write-Host " remote version " -NoNewline
            Write-Host "$remoteVersion" -ForegroundColor $remotecolor

            if (-not $NoUpdate) {
                if ($needsUpdate -or $Force) {
                    if (-not $needsUpdate) { Write-Host "Updating because force is set" }
                    Write-Host "Updating $($module.Name)"
                    $module | Update-Module -Verbose:$VerbosePreference
                }

            }
        }
        if (-not $DisplayOnly) {
            $returnValues += New-Object -Type PSObject -Property $moduleInfo
        }


    }

    $returnObject = $null
    if ($returnValues -ne $null) {
        $returnObject = $returnValues
    }

    return, $returnObject
}