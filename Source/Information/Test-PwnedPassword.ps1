[CmdletBinding()]
param([string]$PwdToTest,
    [switch]$Quiet)

begin {
    Set-StrictMode -version Latest

    $requestString = "https://api.pwnedpasswords.com/range/"

    $sha1 = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider 
    $toHash = [System.Text.Encoding]::UTF8.GetBytes($PwdToTest)
    $stringHash = [System.BitConverter]::ToString( $sha1.ComputeHash($toHash)).Replace("-", "")


}
process {
    
    $prefix = $stringHash.substring(0, 5)
    $remainder = $stringHash.substring(5)

    Write-Verbose "URI      : $requestString"
    Write-Verbose "Prefix   : $prefix"
    write-verbose "Full URI : $requestString$prefix"
    Write-Verbose "Remainder: $remainder"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $results = Invoke-WebRequest -Uri "$requestString$prefix" 
    
    if ($results -match $remainder) {
        
        foreach ($s in $($results.Content -split "`r`n")) {
            $countofHash = $($s -split ":")[1]
            $stringToMatch = $($s -split ":")[0]
            if ($stringToMatch -eq $remainder) {
                if (-not $Quiet) {
                    Write-Host "Password '$pwdToTest' has been used $countOfHash times."
                } else {break; }
            }
        }
    } else {if (-not $Quiet) {Write-Host "No matches found"}}
    if ($Quiet) {$countOfHash}
}