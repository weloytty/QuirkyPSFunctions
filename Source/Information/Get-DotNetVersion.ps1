
[CmdletBinding()]
param(
    [Alias("FQDN")]
    [Parameter(ValueFromPipeline = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
    [string[]]$ComputerName = "$($env:ComputerName)",
    [switch]$DisplayOnly,
    [switch]$Quiet)

begin {
    Write-Verbose "Entering Begin block"
    $ScriptToRun = {


        $VerbosePreference = $using:VerbosePreference

        Write-Verbose "In Script Block"
        Write-Verbose "Display Only is set to $($using:DisplayOnly)"
        Write-Verbose "Quiet is set to $($using:Quiet)"

        if ($using:Quiet -and $using:DisplayOnly) {
            Write-Verbose "Quiet and DisplayOnly were both set, no output will be produced"
        }

        $regKey = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\"

        $clrVersion = Get-ItemProperty $regKey | Select-Object Version -ErrorAction SilentlyContinue
        $release = Get-ItemProperty $regKey | Select-Object Release -ErrorAction SilentlyContinue

        Write-Verbose "Value of Release is $($release)"

        switch ($release.Release) {
            378389 {
                $versionName = ".NET Framework 4.5"
            }
            378675 {
                $versionName = ".NET Framework 4.5.1 installed with Windows 8.1 or Windows Server 2012 R2"
            }
            378758 {
                $versionName = ".NET Framework 4.5.1 installed on Windows 8, Windows 7 SP1, or Windows Vista SP2"
            }
            379893 {
                $versionName = ".NET Framework 4.5.2"
            }
            393295 {
                $versionName = ".NET Framework 4.6"
            }
            393297 {
                $versionName = ".NET Framework 4.6"
            }
            394254 {
                $versionName = ".NET Framework 4.6.1"
            }
            394271 {
                $versionName = ".NET Framework 4.6.1"
            }
            394747 {
                $versionName = ".NET Framework 4.6.2 Preview"
            }
            394748 {
                $versionName = ".NET Framework 4.6.2 Preview"
            }
            394802 {
                $versionName = ".NET Framework 4.6.2"
            }
            394806 {
                $versionName = ".NET Framework 4.6.2"
            }
            460798 {
                $versionName = ".NET Framework 4.7"
            }
            460805 {
                $versionName = ".NET Framework 4.7"
            }
            461310 {$versionName = ".NET Framework 4.7.1"}
            461308 {$versionName = '.NET Framework 4.7.1'}
            461310 {$versionName = ".NET Framework 4.7.2"}
            461814 {$versionName = ".NET Framework 4.7.2"}
            461808 {$versionName = ".NET Framework 4.7.2"}
            default {
                $versionName = $clrVersion.Version
            }
        }

        $paddedName = $($Env:COMPUTERNAME).padRight(15)
        if ($using:Quiet -eq $false) {
            Write-Output "$paddedName is running CLR Version $($clrVersion.Version) ($versionName)"
        }


        [hashtable]$returnValues = @{}
        $returnValues.ComputerName = $Env:COMPUTERNAME
        $returnValues.Version = $clrVersion.Version
        $returnValues.VersionName = $versionName
        $returnValues.KB = $release.Release
        $returnObject = New-Object psobject -Property $returnValues

        if ($using:DisplayOnly) {
            $returnObject = $null
        }

        return $returnObject

    }
}
process {

    #https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
    
    foreach ($server in $ComputerName) {
        Write-Verbose "Processing $server"

        Invoke-Command -ComputerName $server -ScriptBlock $ScriptToRun

    }
}

end {
    Write-Verbose "Entering end block"
}



