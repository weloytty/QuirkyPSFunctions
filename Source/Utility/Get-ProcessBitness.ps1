[CmdLetBinding()]
param([string[]]$ComputerName,
    [string]$ProcessName)

begin {


    $sb = {
        param($ProcessName)

        Add-Type -MemberDefinition @'
        [DllImport("kernel32.dll", SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool IsWow64Process(
            [In] System.IntPtr hProcess,
            [Out, MarshalAs(UnmanagedType.Bool)] out bool wow64Process);
'@ -Name NativeMethods -Namespace Kernel32

        Get-Process -Name $ProcessName | Foreach-Object {
            $is32Bit = [int]0 
            if ([Kernel32.NativeMethods]::IsWow64Process($_.Handle, [ref]$is32Bit)) { 
                "$($_.Name) $($_.Id) is $(if ($is32Bit) {'32-bit'} else {'64-bit'})" 
            } else {"IsWow64Process call failed"}
        }
    }


    if ($null -eq $ComputerName) {$ComputerName = @('.')}

}


process {


    foreach ($c in $ComputerName) {

        if ($c -eq '.') {
            invoke-command -scriptblock $sb    
        } else {
            if (Test-Port -Port 3389 -ComputerName $s) {
                invoke-command -computername $c -scriptblock $sb
            } else {Write-Output "Can't connect to $c"}
        }

        
    }
    

}