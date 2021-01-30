
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$ModuleName,
    [switch]$StayIfNotFound
)

begin {
    Set-StrictMode -Version Latest
}

process {

    $pathToSet = $($env:PSModulePath -split ";" -match $env:USERNAME)[0]

    Write-Verbose "Path to set is originally $pathToSet"
    Write-Verbose "Looking for $ModuleName"

    if ($null -ne $ModuleName -and $ModuleName.Length -gt 0) {
        Write-Verbose "Invoking Get-Module -Name $ModuleName -ErrorAction SilentlyContinue"
        $thisModule = $(Get-Module -Name "$ModuleName" -ErrorAction SilentlyContinue)
        if ($null -ne $thisModule) {
            Write-Verbose "Found $ModuleName in $($thisModule.Path)"
            $pathToSet = $thisModule.ModuleBase}
        if ($null -eq $thisModule) {
            Write-Verbose "Can't find $ModuleName. Trying Get-Module with -ListAvailable"
            $thisModule = Get-Module -Name $ModuleName -ListAvailable -ErrorAction SilentlyContinue
        }

        if ($null -eq $thisModule) {
            Write-Verbose "Can't find $ModuleName. Trying Get-DSCResource "
            $thisModule = Get-DscResource -Module $ModuleName -ErrorAction SilentlyContinue
        }

        if ($null -eq $thisModule) {
            $count = $thisModule | Measure-Object | Select-Object -ExpandProperty Count
            if ($count -gt 1) {
                Write-Verbose "There are $count versions of $ModuleName"
                if ($VerbosePreference) {
                    for ($i = 0; $i -lt $count; $i++) {
                        Write-Verbose "$($thisModule[$i].ModuleBase)"
                    }
                    Write-Verbose ""
                }
                $thisModule = $thisModule[0]
            }
            Write-Verbose "Setting to $thisModule at $($thisModule.Path)"
            $pathToSet = Split-Path -Parent $thisModule.Path
        }
        else {
            if ($StayIfNotFound) { $pathToSet = '' }
        }
    }
    if ($pathToSet.Length -gt 0) {
        Write-Verbose "Setting Path $pathToSet"
        Set-Location "$pathToSet"
    }

}

