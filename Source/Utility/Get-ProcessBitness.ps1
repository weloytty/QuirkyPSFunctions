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

        Get-Process -Name $ProcessName | ForEach-Object {
            $is32Bit = [int]0 
            if ([Kernel32.NativeMethods]::IsWow64Process($_.Handle, [ref]$is32Bit)) { 
                "$($_.Name) $($_.Id) is $(if ($is32Bit) {'32-bit'} else {'64-bit'})" 
            } else { "IsWow64Process call failed" }
        }
    }

    if ($null -eq $ComputerName) { $ComputerName = @('.') }

}


process {


    foreach ($c in $ComputerName) {

        if ($c -eq '.') {
            Invoke-Command -ScriptBlock $sb    
        } else {
            #changed 3389 to 5985, because 5985 is WinRM
            if (Test-Port -Port 5985 -ComputerName $s) {
                Invoke-Command -ComputerName $c -ScriptBlock $sb
            } else { Write-Output "Can't connect to $c" }
        }

        
    }
    

}