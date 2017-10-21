[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Name',ValueFromPipeline=$true)]
    [string[]]$ModuleName,
    [Parameter(ParameterSetName = 'Module', Position = 0, Mandatory = $true,ValueFromPipeline=$true)]
    [System.Management.Automation.PSModuleInfo[]]$Module,
    [switch]$All)
    

begin {
    $returnValue = @()
    if ($ModuleName) {
        $Module = @()
        foreach ($name in $ModuleName) {
            $Module += $(Get-Module -Name $name)
        }
    
    }
}
process {
    if ($Module.Length -eq 0) {
        Write-Output "No modules specified"
    }
    else {
        foreach ($currentModule in $Module) {
            $returnValue += $Module.Version
        }
    }
}

end {
    return $returnValue
}