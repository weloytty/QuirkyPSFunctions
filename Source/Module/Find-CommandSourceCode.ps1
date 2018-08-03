
[CmdletBinding()]
param(
    [string[]]$Name
)
begin {
    Set-StrictMode -Version Latest
    $arrayToReturn = @()
}
process {

    foreach ($commandName in $name) {


        $sourceFile = ''
        $binaryFile = $false
        Write-Verbose "Finding $commandName"

        $command = (Get-Command $commandName -ErrorAction SilentlyContinue)

        if ($command -eq $null) { throw "Can't find $commandName" }

        if ($command.CommandType -eq "Alias") {
            $expandedCommand = $(Get-Alias $command).Definition
            Write-Verbose "Expanded alias $command to $expandedCommand"
            $command = $(Get-Command $expandedCommand)
        }


        Write-Verbose "$($command.Name) source is from $($command.Source), which is a $($command.CommandType)"


        if (($command.CommandType -eq "Function") -or ($command.CommandType -eq "Filter")) {
            $module = $command.Source

            if ($module -eq "Quirky.Module") { $module = "Quirky" }

            Write-Verbose "Module is $module"
            if ($module -ne "" -and $module -ne $null) {

                if ($module -ne "Quirky") { Import-Module -Name $module }

                Write-Verbose "Getting Module $module"

                $sourceFile = $(Get-Module $module).Path

                Write-Verbose "Source to $($command.Name) appears to be $($sourceFile)"

                $thisModule = Get-Module $module
                $thisModule = Get-HighestModuleVersion($thisModule)

                if ($thisModule.NestedModules.Count -gt 0) {
                    Write-Verbose "BUT, $(Split-Path $sourceFile -Leaf) has NestedModules!"
                    Write-Verbose "dunDunDUNNNNNNNN.jpg"
                    if ($thisModule.ExportedFunctions[$command].Source -ne $module) {
                        Write-Verbose "Nested module is $($thisModule.ExportedCommands[$command].Module.Name), which is a $($thisModule.ModuleType)"
                        if ($thisModule.ModuleType -eq "Script") {
                            $sourceFile = $thisModule.ExportedFunctions[$command].Module.Path
                        } else {
                            Write-Verbose "I don't know what to do with $($thisModule.ModuleType)"
                        }
                    }
                } else {
                    Write-Verbose "Can't find a source for $($command.Name), using profile"
                    if ($sourceFile -eq '') { $sourceFile = $PROFILE }
                }
            } else {
                Write-Verbose "Can't find a source for $($command.Name).  Returning $PROFILE"
                if ($sourceFile -eq $null -or $sourceFile -eq '') {
                    if (Test-Path $PROFILE) {
                        $sourceFile = $PROFILE
                    }
                }
            }


            Write-Verbose "Source: `'$sourceFile`'"

            if (($sourceFile -ne '') -and (-not (Test-Path $sourceFile))) {
                Write-Verbose "Test-Path $sourceFile returns $(Test-Path $sourceFile)"
                $sourceFile = $null
            }


        }
        if ($command.CommandType -eq "CmdLet") {
            $sourceFile = $command.DLL
            $binaryFile = $true
        }
        if ($command.CommandType -eq "ExternalScript") {
            $sourceFile = $command.Source

        }

        [hashtable]$returnValues = @{}

        if (($sourceFile -ne $null) -and ($sourceFile -ne '')) {
            $returnValues.FileInfo = $(Get-Item $sourceFile)
            $returnValues.Definition = $command.Definition
        } else {
            $returnValues.FileInfo = $null
        }
        if ($binaryFile -eq $false) {
            $returnValues.Path = $sourceFile
        }


        $arrayToReturn += $(New-Object -Type psobject -Property $returnValues)
    }



}
end {
    return $arrayToReturn
}

