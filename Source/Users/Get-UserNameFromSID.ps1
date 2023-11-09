    [CmdletBinding()]
    param([string[]]$Sid)
    begin {
        Set-StrictMode -Version Latest
    }
    process {
        foreach ($thisSid in $Sid) {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier($thisSid) 
            $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
            $objUser.Value
        }
    }
    end {

    }