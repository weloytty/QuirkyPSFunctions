[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string[]]$DataToEncode)

begin {
    Set-StrictMode -Version Latest
}
process { 

    foreach ($s in $DataToEncode) {
        [System.Web.HttpUtility]::UrlEncode("$s")
    }

}



