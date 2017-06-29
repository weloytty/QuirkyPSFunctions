[CmdletBinding()]
Param([string]$enum)

# get-enumValues -enum "System.Diagnostics.Eventing.Reader.StandardEventLevel"

$enumValues = @{}

[enum]::getvalues([type]$enum) |

ForEach-Object { 
    $enumValues.add($_, $_.value__)
}

$enumValues


