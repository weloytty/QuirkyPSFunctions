[CmdLetBinding()]    
param(
    [Parameter(Mandatory = $true)]
    [string]$computername
)
# Stolen from https://www.leeholmes.com/blog/2009/11/20/testing-for-powershell-remoting-test-psremoting/   
try {
    $errorActionPreference = "Stop"
    $result = Invoke-Command -ComputerName $computername { 1 }
} catch {
    Write-Verbose $_
    return $false
}
   
## I've never seen this happen, but if you want to be
## thorough....
if ($result -ne 1) {
    Write-Verbose "Remoting to $computerName returned an unexpected result."
    return $false
}
   
$true   
