[CmdletBinding()]
param([string]$InputNumber
)

begin {
    Set-StrictMode -Version Latest   

    $isNumber = ($InputNumber -match '\d')
    Write-Verbose "$InputNumber Is a Number = $IsNumber"

    if(-not $InputNumber.ToLower().StartsWith("0x")){$InputNumber = "0x$InputNumber"}

}

process {
    try {
        Write-Output "$('{0:d}' -f [int]$InputNumber)"
    }
    catch {
        $null
    }
    
}

