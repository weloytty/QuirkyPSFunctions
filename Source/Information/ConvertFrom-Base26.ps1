[CmdletBinding()]
param([parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string] $value)
begin {
    Set-StrictMode -Version Latest
    $alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
$BASE=26
}
process {
    $inputArray = $value.ToUpper().ToCharArray();
    
    [long]$decNum = 0;
[int]$pos = 0
    for ([int]$i = 0; $i -lt $inputArray.Length; $i++) {
        

        Write-Verbose "$([byte][char]$inputArray[$i]) $([byte][char]'A')"
        $decNum *= 26

        $decNum += $([byte][char]$inputArray[$i] - [byte][char]'A' + 1 )
        #$decNum += $($($alphabet.IndexOf($currVal))  * ([long][Math]::Pow($BASE, $pos) ))
      $pos++
    }
   
     
    
}
end {
    return $decNum -1
}