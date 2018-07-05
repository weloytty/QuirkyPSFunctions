[CmdletBinding()]
param([long]$Size)
process {

    switch ($Size) {
        {$_ -ge 1PB} {"{0:0000.##' P'}" -f ($size / 1PB); break}
        {$_ -ge 1TB} {"{0:0000.##' T'}" -f ($size / 1TB); break}
        {$_ -ge 1GB} {"{0:0000.##' G'}" -f ($size / 1GB); break}
        {$_ -ge 1MB} {"{0:0000.##' M'}" -f ($size / 1MB); break}
        {$_ -ge 1KB} {"{0:0000.##' K'}" -f ($size / 1KB); break}
        default {"{0:0000.##}" -f ($Size) + " B"}
    }
}