
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [string[]]$inputURLs,
    [switch]$NavigateToURL,
    [switch]$ShowIntermediateURLs)
begin {
    Add-Type -AssemblyName System.Web
}
process {
    foreach ($inputURL in $InputURLs) {
        $escapedURL = [System.Web.HttpUtility]::UrlEncode($inputURL)
        $a = (Invoke-RestMethod https://lengthenurl.info/api/longurl/shorturl/?inputURL=$escapedURL)
        Write-Output $a.LongURL

        if ($ShowIntermediateURLs) {
            Write-Output ""
            Write-Output "Intermediate URLS"
            foreach ($s in $a.IntermediateURLs) {
                Write-Output "     $s"
            }
            Write-Output ""
        }
        if ($NavigateToURL)
        { Start-Process $a.LongURL }
        else {
            #PSCX has a better Set-Clipboard, but I don't want a dependency
            Set-ClipboardText $a.LongURL
        }


    }
}


