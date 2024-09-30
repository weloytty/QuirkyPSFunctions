
[CmdletBinding()]
param(
    [Alias('Name')]
    [Parameter(Mandatory = $true)]
    [string]$CommandToFind,
    [switch]$Details
)
$a = Get-Command $CommandToFind -ErrorAction SilentlyContinue
if ($null -ne $a) {
    $article = 'a'
    if ($a.CommandType -eq 'Alias' -or $a.CommandType -eq 'Application') { $article = 'an' }
    Write-Verbose "$CommandToFind is $article $($a.CommandType)"
    switch ($a.CommandType) {
        "Application" { $output = $a.Source }
        "CmdLet" { $output = $a.Source }
        "Filter" { $output = $a.Source }
        "ExternalScript" { $output = $a.Source }
        "Alias" {
            $def = $a | Select-Object -ExpandProperty Definition
            Write-Verbose "$CommandToFind is an alias for $def"
            if ($null -ne $def) {
                $output = Get-CommandSource -CommandToFind $def -Details:$Details
            }

        }
        default { $output = $a.Source }
    }
    Write-Output $output
}


