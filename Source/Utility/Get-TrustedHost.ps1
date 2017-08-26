
[CmdletBinding()]
param([string[]]$ComputerName = 'localhost',
    [switch]$ViewOnly,
    [switch]$OverWriteAll,
    [switch]$Force)

begin {
    Set-StrictMode -Version Latest
}
process {

    if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        foreach ($Computer in $ComputerName) {
            if (Test-Path wsman::$Computer\client\trustedhosts) {
                $currentValue = (Get-Item -Path wsman::localhost\client\TrustedHosts).Value

                Write-Output "Current Value is $currentValue"
            }

        }


    } else { Write-Error "No admin rights. Run elevated." }

}


