[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,ValueFromPipeLine=$true,Position=0)]
    [object]$ObjectToTest,
    [Parameter(Mandatory = $true, ValueFromPipeLine = $true, Position = 1)]
    [string]$PropertyName
    )

begin {
    Set-StrictMode -Version Latest
    $returnValue = $false
}

process{
    if ($null -ne $ObjectToTest) {
        $returnValue = [bool]($ObjectToTest.PSObject.Properties.Name -match $PropertyName)
    } else {Write-Verbose "Can't evaluate Null object"}

    
}

end {
    return $returnValue
}