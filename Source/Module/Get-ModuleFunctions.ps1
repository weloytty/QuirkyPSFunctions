
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
    [string[]]$Name,
    [ValidateSet('CmdLet', 'Alias', 'Function', 'Filter', 'All')]
    [string]$CommandType = 'All',
    [switch]$Quiet,
    [switch]$DisplayOnly
)

begin {
    Set-StrictMode -Version Latest



    $returnValue = @()
}
process {

    if ($Quiet -and $DisplayOnly) {
        Write-Verbose "Quiet and DisplayOnly are both set.  No output will be produced"
    }

    $ModuleName = $Name

    if ($null -ne $ModuleName) {
        foreach ($thisModuleName in $ModuleName) {
            Write-Verbose "Processing module $thisModuleName"
            $return = @{}
            $return.Module = ""
            $return.FunctionInfo = @()
            $return.AliasInfo = @()
            $return.FilterInfo = @()
            $return.CmdletInfo = @()

            if ($thisModuleName -ne "Quirky") {
                Import-Module -Name $thisModuleName -ErrorAction SilentlyContinue
            }



            $modbyName = $(Get-Module -Name $thisModuleName -ErrorAction SilentlyContinue)
            if ($null -eq $modByName ) {
                $modbyName = $(Get-Module -Name $thisModuleName -ListAvailable -ErrorAction SilentlyContinue)
            }

            if ($null -eq $modByName ) {
                #if there are multiple versions of a module, this will load the latest

                $modbyName = $(Get-Module -Name $thisModuleName -ErrorAction SilentlyContinue)
            }




            if ($null -ne $modByName) {

                if ([bool]($modbyName.PSObject.Properties.Name -match "Count")) {
                    if ($modbyName.Count -gt 1) {

                        $modByName = Get-HighestModuleVersion $modByName -Verbose:$VerbosePreference
                    }
                }


                $return = @{}
                $return.Module = $modByName.Name
                $return.FunctionInfo = @()
                $return.AliasInfo = @()
                $return.FilterInfo = @()
                $return.CmdletInfo = @()
                $return.ResourceInfo = @()

                if (($null -ne $modByName.ExportedCommands ) -and ($null -ne $modByName.ExportedCommands.Values)) {
                    Write-Verbose "Module is not null, getting exported commands"
                    if ($null -ne $modbyName.ExportedCommands -and $modbyName.ExportedCommands.Count -gt 0) {
                        $functionByName = $($modbyName.ExportedCommands.Values.Name)
                    }
                    if ($($null -ne $modbyName.ExportedDscResources )) {
                        if($modByName.ExportedDscResources.Count -gt 0){
                        $functionsByName += $($modbyName.ExportedDscResources.Values.Name)
                        }else{Write-Verbose "No DSC Resources"}
                    }

                    if ($VerbosePreference) { Write-Verbose $($modByName |ForEach-Object {Write-Verbose $("$($_.CommandType) $($_.Name)")}) }

                    if ($CommandType -ne 'All') {
                        $functionByName = $($functionByName | Where-Object { $_.CommandType -eq $CommandType })
                    }
                    $functionByName = $($functionByName | Sort-Object CommandType, Name)


                    $return.Module = $modByName.Name
                    $return.FunctionInfo = @()
                    $return.AliasInfo = @()
                    $return.FilterInfo = @()
                    $return.CmdletInfo = @()




                    $testModule = Get-Module -Name $thisModuleName -ErrorAction SilentlyContinue
                    $imported = $false
                    if ($null -eq $testModule) {
                        Import-Module -Name $thisModuleName
                        $imported = $true
                    }

                    #
                    #for($counter=0;$counter -lt $($modbyName.ExportedCommands.Count);$counter++)
                    $functionNumber = -1
                    foreach ($g in $functionByName) {

                        $functionNumber++
                        Write-Verbose "Working on function $g Number $functionNumber"
                        $f = $(Get-Command $modByName.ExportedCommands[$g] -ErrorAction SilentlyContinue)



                        if ($null -eq $f ) {
                            Write-Verbose "Getting Command by function number $functionNumber"
                            $f = $(Get-Command $modByName.ExportedCommands[$functionNumber] -ErrorAction SilentlyContinue)
                        }


                        Write-Verbose "Getting information for $f"


                        [hashtable]$commandInfo = @{}
                        $commandInfo.CommandType = $f.CommandType
                        $commandInfo.Name = $f.Name
                        #$returnList += $(New-Object -Type PSObject -Property $commandInfo)

                        Write-Verbose "Command Type $($f.CommandType)"
                        switch ($f.CommandType) {
                            "Function" { $return.FunctionInfo += $(New-Object -Type PSObject -Property $commandInfo) }
                            "Alias" {
                                $aliasInfo = $(Get-Command $f -ErrorAction SilentlyContinue)


                                if ($null -ne $aliasInfo ) {

                                    if ([bool]($commandInfo.PSobject.Properties.name -match "ResolvedCommand")) {
                                        $commandInfo.ResolvedCommand = $($aliasInfo| Select-Object -ExpandProperty ResolvedCommand)
                                        $return.AliasInfo += $(New-Object -Type PSObject -Property $commandInfo)
                                        $aliasInfo = $null

                                    }
                                }
                            }
                            "Filter" { $return.FilterInfo += $(New-Object -Type PSObject -Property $commandInfo) }
                            "Cmdlet" { $return.CmdletInfo += $(New-Object -Type PSObject -Property $commandInfo) }

                            default { Write-Host "Unknown CommandType $($f.CommandType) for $($f.Name)" }
                        }



                    }

                    if ($imported) { Remove-Module -Name $modByName -ErrorAction SilentlyContinue }

                } else { Write-Verbose "No exported commands in $thisModuleName" }
            }
            $returnValue += $(New-Object -Type PSObject -Property $return)



        }
    }
}
end {

    function WriteInformation () {
        param($functionGroup)

        $headerWritten = $false
        foreach ($a in $functionGroup | Sort-Object Name) {
            if (-not $headerWritten) {
                $headerWritten = $true
                Write-Host "$($a.CommandType.ToString().padRight(10))"
                Write-Host "----------"
            }
            Write-Host "$($a.CommandType.ToString().padRight(10)) $($a.Name.ToString())"
        }
        if ($headerWritten) { Write-Host "" }
    }

    if (-not $Quiet) {
        Write-Host ""
        foreach ($s in $returnValue) {
            $headerWritten = $false
            foreach ($a in $s.AliasInfo) {
                if (-not $headerWritten) {
                    $headerWritten = $true
                    Write-Host "$($a.CommandType.ToString().padRight(10))"
                    Write-Host "----------"
                }
                $t = $a.CommandType.ToString().padRight(10)
                $n = $a.Name.ToString()
                $r = $a.ResolvedCommand.ToString()
                Write-Host "$t $n ($r)"

            }
            if ($headerWritten) { Write-Host "" }

            WriteInformation ($s.FunctionInfo)
            WriteInformation ($s.CmdletInfo)
            WriteInformation ($s.FilterInfo)



        }



    }
    if ($DisplayOnly) { $returnValue = $null }

    return $returnValue
}

