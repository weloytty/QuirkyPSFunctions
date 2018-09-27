[CmdletBinding()]
param([parameter(Mandatory=$true,ValueFromPipeline=$true)]
[int] $value)
begin{
Set-StrictMode -Version Latest
}
process{
    $currVal = $value;
    $returnVal = '';
    while ($currVal -ge 26) {
        $returnVal = [char](($currVal) % 26 + 65) + $returnVal;
        $currVal =  [int][math]::Floor($currVal / 26)
    }
    #$returnVal = [char](($currVal) + 64) + $returnVal;
    $returnVal = [char](($currVal) + 65) + $returnVal;
     
    return $returnVal
}
end{

}