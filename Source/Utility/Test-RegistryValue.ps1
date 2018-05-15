[CmdletBinding()]
param(
    [Alias("PSPath")]
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [String]$Path    ,
    [Parameter(Position = 1, Mandatory = $true)]
    [String]$Name    ,
    [Switch]$PassThru
) 

process {
    if (Test-Path $Path) {
        $Key = Get-Item -LiteralPath $Path
        if ($Key.GetValue($Name, $null) -ne $null) {
            if ($PassThru) {
                Get-ItemProperty $Path $Name
            } else {
                $true
            }
        } else {
            $false
        }
    } else {
        $false
    }
}
