[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string[]]$ComputerName,
    [Parameter(Mandatory = $true)]
    [string]$MofPath,
    [switch]$Quiet,
    [switch]$DisplayOnly,
    [switch]$TestOnly)


begin {
    Set-StrictMode -Version Latest

    function Get-ConfigStatus {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
            [string]$ComputerName,
            [string]$MofPath,
            [switch]$Quiet)

        $paddedComputer = $ComputerName.padRight(16)
        Write-Verbose "Test-DscConfiguration -ComputerName $computer -Path $mofPath -ErrorAction SilentlyContinue"
        $results = Test-DscConfiguration -ComputerName $computer -Path $mofPath -ErrorAction SilentlyContinue
        if (-not $Quiet) {
            Write-Host ""
            Write-Host "$paddedComputer Configuration: $(Split-Path $mofPath -Leaf) ($mofPath)"
        }

        if ($null -ne $results -and (-not $Quiet)) {

            foreach ($ids in $results.ResourcesInDesiredState) {

                $paddedConfiguration = $ids.ResourceID.padRight(40)
                Write-Host "  $paddedConfiguration In Desired State"
            }
            foreach ($nds in $results.ResourcesNotInDesiredState) {
                $paddedConfiguration = $nds.ResourceID.padRight(40)
                Write-Host "  $paddedConfiguration " -NoNewline
                Write-Host "NOT In Desired State" -ForegroundColor Red
            }
            Write-Host ""

        } else {
            if (-not $Quiet) {

                Write-Host "$($error[0].ToString())" -ForegroundColor Red
                Write-Host ""
            }

        }
        return $results
    }
    if (-not (Test-Path $mofPath)) { throw "Can't find $mofPath" }
    $mofRoot = (Get-Item $mofPath).FullName

    $returnValues = @()

}

process {
    if (-not (Test-Path -Path $mofRoot -PathType Container)) { throw "Invalid Path $mofRoot" }
    foreach ($Computer in $ComputerName) {

        [hashtable]$theseResults = @{}
        $theseResults.ComputerName = $computer
        $theseResults.StatusInfo = @()

        if (Test-Port -ComputerName $Computer --Quiet -Port 3389 -ErrorAction SilentlyContinue) {

            $runFirst = $(Join-Path $MofRoot 'runfirst')
            if (Test-Path $(Join-Path $runFirst "$computer.mof")) {
                $results = (Get-ConfigStatus $Computer $runFirst -Quiet:$Quiet -Verbose:$VerbosePreference)
                [hashtable]$info = @{}
                if ($null -ne $results) {

                    $info.ConfigName = (Split-Path $runFirst -Leaf)
                    $info.InDesiredState = $results.InDesiredState
                    $info.StatusInfo = $results
                }
                $infoObject = New-Object -Type PSObject -Property $info
                $theseResults.StatusInfo += $infoObject

            } else {
                if (-not $Quiet) { Write-Host "No config for $computer at $runFirst" }
            }


            $mofFolders = (Get-ChildItem -Path $MofRoot -Directory -Exclude 'runfirst')
            if ($null -eq $mofFolders ) {
                Write-Verbose "$mofFolders is null!"
                $mofFolders = Get-Item $mofRoot
            }

            foreach ($folder in $mofFolders) {
                $fl = $folder.FullName

                if (Test-Path $(Join-Path $fl "$computer.mof")) {
                    $results = (Get-ConfigStatus $computer $fl -Quiet:$Quiet)
                    [hashtable]$info = @{}
                    $info.ConfigName = (Split-Path $fl -Leaf)
                    $info.InDesiredState = $false
                    $info.StatusInfo = $null

                    if ($null -ne $results -and ($results.PSObject.Properties.Name -match "InDesiredState")) {
                        $info.InDesiredState = $results.InDesiredState
                        $info.StatusInfo = $results
                    }
                    $infoObject = New-Object -Type PSObject -Property $info
                    $theseResults.StatusInfo += $infoObject
                } else { if (-not $Quiet) { Write-Host "No config for $computer at $fl" } }

            }

        }
        $resultsObject = New-Object -Type PSObject -Property $theseResults
        $returnValues += $resultsObject

    }

}

end {
    if ($DisplayOnly) { $returnValues = $null }
    return, $returnValues
}

