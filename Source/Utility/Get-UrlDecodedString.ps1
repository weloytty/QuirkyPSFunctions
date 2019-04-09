[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string[]]$DataToDecode)

begin {
    Set-StrictMode -Version Latest
}
process { 

    foreach ($s in $dataToDecode) {
        [System.Web.HttpUtility]::UrlDecode("$s")
    }

}