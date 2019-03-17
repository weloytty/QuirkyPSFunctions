[CmdletBinding()]
param([int]$InputNumber
)


begin {
    Set-StrictMode -Version Latest   

}

process {
    try {
        Write-Output "$('{0:x}' -f $InputNumber)"
    } catch {
        $null
    }
}

