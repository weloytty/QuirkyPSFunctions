
[CmdLetBinding()]
param (
    [Alias('FQDN')]
    [string[]]$ComputerName = @('.'))

begin {

    if (-not $IsWindows) { throw 'Unsupported platform' }

    $hklm = 2147483650
    $regPath = 'Software\Microsoft\Windows NT\CurrentVersion'
    $regValue = 'DigitalProductId'
}
process {

    foreach ($target in $ComputerName) {
        $productKey = $null
        $win32os = $null
        $wmi = [CimClass] $(Get-CimClass -Namespace root\cimv2 -ClassName StdRegProv -ComputerName $target)
	
        $data = $(Invoke-CimMethod -InputObject $wmi -Name GetBinaryValue -Arguments @{hDefKey = $hklm; sSubKeyName = $regPath; sValueName = $regValue })
        #$data = $wmi.CimClassMethods["GetBinaryValue"]($hklm, $regPath, $regValue)
        $binArray = ($data.uValue)[52..66]
        $charsArray = 'B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'M', 'P', 'Q', 'R', 'T', 'V', 'W', 'X', 'Y', '2', '3', '4', '6', '7', '8', '9'
        ## decrypt base24 encoded binary data
        if ($null -ne $binArray) {
            For ($i = 24; $i -ge 0; $i--) {
                $k = 0
                For ($j = 14; $j -ge 0; $j--) {
                    $k = $k * 256 -bxor $binArray[$j]
                    $binArray[$j] = [math]::truncate($k / 24)
                    $k = $k % 24
                }
                $productKey = $charsArray[$k] + $productKey
                If (($i % 5 -eq 0) -and ($i -ne 0)) {
                    $productKey = '-' + $productKey
                }
            }
        }
        $win32os = Get-CimInstance -ClassName Win32_OperatingSystem -computer $target
        $obj = New-Object Object
        $obj | Add-Member Noteproperty Computer -Value $target
        $obj | Add-Member Noteproperty Caption -Value $win32os.Caption
        $obj | Add-Member Noteproperty CSDVersion -Value $win32os.CSDVersion
        $obj | Add-Member Noteproperty OSArch -Value $win32os.OSArchitecture
        $obj | Add-Member Noteproperty BuildNumber -Value $win32os.BuildNumber
        $obj | Add-Member Noteproperty RegisteredTo -Value $win32os.RegisteredUser
        $obj | Add-Member Noteproperty ProductID -Value $win32os.SerialNumber
        $obj | Add-Member Noteproperty ProductKey -Value $productkey
        $obj
    }

}
end {}