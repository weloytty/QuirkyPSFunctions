

[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline = $true, Position = 0)]
    [object]$InputObject)
Write-Verbose "Input Object Type: $($InputObject.GetType())"
 
foreach ($member in $InputObject.PSObject.Properties) {

    Write-Output "$($member.Name.padRight(30)) $($InputObject.$($member.Name))"
}

