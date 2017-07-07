[CmdletBinding()]
param([switch]$IncludeAzure)

begin {
    Set-StrictMode -Version Latest
}

process {
    if ($IncludeAzure) {
        Get-Command *DSC*
    } else {
        Get-Command *DSC*|Where-Object {-not ($_.Source -match 'Azure')}
    }

}