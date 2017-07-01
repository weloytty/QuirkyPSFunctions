[CmdletBinding()]
param()
#
# defaultPSake.ps1
#
# PSAke to build and deploy
#  Tasks are, in order
#
#  TestProperties:  Makes sure properties are set right
#  PreBuild      :  Makes sure all source files and folders exist
#                   And validates manifest
#  Deploy        :  Copies source to destination.
#  Test          :  Runs pester tests on DEPLOYED module
#
#  if you Invoke-PSake with no args, you'll get PreBuild
#  If you want to deploy and make sure the deployment is
#  OK, Invoke-PSAke with -TaskList Test
#
#  Other Tasks:
#
#  Clean        : DELETES the target folder and removes
#                 the module from your modules
#
#  RemoveOld    : Deletes the version of Quirky before
#                 I gave it that spiffy name
#

Set-StrictMode -Version Latest  

Include ".\buildFunctions.ps1"

Properties {

    $m_moduleName = "Quirky"
    $m_newBuild = $true
    $m_buildPath = $psake.build_script_file

    $m_sourceFolder = "Source"
    $m_outputFolder = "Output"

    $m_buildParent = $(Split-Path $m_buildPath -Parent)

    $m_sourcePath = Join-Path $(Split-Path $m_buildParent -Parent) "Source"
    $m_outputPath = Join-Path $(Split-Path $m_buildParent -Parent) "Output"
    $m_Tests = Join-Path $(Split-Path $m_buildParent -Parent) "Tests"

    $script:m_ModuleVersion = "1.2.0.0"
   

    $m_PersonalFunctions = "PersonalFunctions"
    $m_firstTestToRunTag = @( "runfirst")
    #$m_destinationPath = $(Join-Path $(Split-Path $PROFILE -Parent) "Modules\$m_ModuleName")
    #$m_destinationPath = Join-Path "$($Env:ProgramFiles)\WindowsPowerShell\Modules" "\Quirky"
   

}

$scriptPath = Split-Path $myinvocation.MyCommand.Source
Push-Location 
Set-Location $scriptPath



FormatTaskName "-------- {0} --------"


#Main tasks

Task default -depends TestProperties
Task Full -depends TestProperties, BuildModule, DeployModule, Test
Task FullNoTest -depends TestProperties, BuildModule, DeployModule
Task CleanBuild -depends TestProperties, Clean, BuildModule, DeployModule, Test


Task Clean -depends TestProperties -Description "Cleans out the destination module folder" {

    Write-Host "Starting Task Clean"
    if (Test-Path $m_outputPath -PathType Container) {
        if ((Get-Module -Name $m_ModuleName -ErrorAction SilentlyContinue) -ne $null) {
            Remove-Module $m_ModuleName -Force
        }

        Write-Verbose "Removed Module"
        Assert ((Get-Module $m_ModuleName) -eq $null) -failureMessage "$m_ModuleName not unloaded"

        Write-Verbose "Removing files from $m_outputPath"
        $toDelete = Get-ChildItem $m_outputPath
        foreach ($deleteFolder in $toDelete) {
            Write-Verbose "Remove-Item $($deleteFolder.FullName) -recurse -force"
            remove-item $($deleteFolder.FullName) -recurse -force
            Assert (-not (Test-Path $($deleteFolder.FullName) -PathType Container)) -failureMessage "$m_outputPath not deleted"
        }

    }
    else {
        Write-Verbose "$m_outputPath not available"
    }
    Write-Host "Task Clean Succeeded"

}




Task -Name Test -depends TestProperties -Description "Runs Pester Test" {

    Write-Host "Running Tests from $m_Tests"
    Write-Verbose "Getting Pester Module"
    $pesterModule = (Get-Module -Name "Pester")
    if ($pesterModule -eq $null) {
        $pesterModule = (Get-Module -Name "Pester" -ListAvailable)
        Assert ($pesterModule -ne $null) -failureMessage "Can't Load Pester"
        Import-Module -Name Pester
    }
    Write-Verbose "Getting Module $m_moduleName"
    $thisModule = (Get-Module -Name $m_moduleName)
    if ($thisModule -ne $null) {
        Import-Module -Name $m_moduleName -Force
    }


    Assert ((Test-Path -Path $m_Tests -PathType Container)) -failureMessage "Can't find path $m_tests"


    if ($m_firstTestToRunTag -ne '') {
        Invoke-Pester -Tag $m_firstTestToRunTag
    }



    Invoke-Pester $m_tests -ExcludeTag $m_firstTestToRunTag

    Write-Host "Running Tests succeded"

}


Task -Name DeployModule -depends TestProperties -Description "Deploys the files" {
    $psdPath = $(Join-Path $m_outputPath "$script:m_moduleVersion") 
    $psdFile = $(Join-path $psdPath "\Quirky.psd1") 
    
    Write-Output "Deploy $m_outputPath"
    Write-output "Version $m_Moduleversion"

    $modPath = $(Join-Path "$PROFILEROOT" "Modules\Quirky")
    $versionPath = $(Join-Path "$modPath" "$script:m_moduleVersion")
    if (Test-Path -Path $versionPath) {Remove-Item $versionPath -Recurse -force }
    Write-Output "Copying $psdPath to $versionPath"
    Copy-Item $psdPath -Destination $versionPath -Recurse


}


Task -Name BuildModule -depends TestProperties -Description "Deploys the files" {

    $psdFile = Join-Path $m_sourcePath "$m_ModuleName.psd1"
    $psmFile = Join-Path $m_sourcePath "$m_ModuleName.psm1"
    $prefsFile = Join-Path $m_sourcePath "$m_ModuleName.Preferences.ps1"
    Write-Host "PSD: $PSDFile"
    Write-Host "PSM: $PSMFile"

    $moduleVersion = $script:m_ModuleVersion.ToString()

    Write-Host "Starting Build"

    Write-Host "PSD File: $psdFile"
    Write-Host "Module  : $m_ModuleName"
    $currentVersion = New-Object -TypeName System.Version -ArgumentList $script:m_ModuleVersion
    $thisModule = (Get-Module -Name $m_ModuleName -ListAvailable -ErrorAction SilentlyContinue)
    Write-Host "Build preset is version $($script:m_ModuleVersion)"
    if ($thisModule -ne $null) {
        Write-Host "Using version from $m_ModuleName"
        $currentVersion = $thisModule.Version

    }
    $script:m_ModuleVersion = $currentVersion.ToString()
    if (Test-Path $psdFile -PathType Leaf) {
        Write-Host "Updating version from $(Split-Path $psdFile -Parent)"
        $newCurrentVersion = Test-ModuleManifest -Path $psdFile|Select -ExpandProperty Version
        $script:m_ModuleVersion = $newCurrentVersion
    }

    Write-Host "Loading $m_ModuleName"

    $modulePath = Get-Module Quirky|Select-Object ModuleBase # Join-Path "$($Env:ProgramFiles)\WindowsPowerShell\Modules" "Quirky"



    Write-Host "Current Version in manifest is $script:m_ModuleVersion"

    if ($m_newBuild) {

        $newRevision = "$($m_ModuleVersion.Major).$($m_ModuleVersion.Minor).$($m_ModuleVersion.Build).$([int]$m_ModuleVersion.Revision +1)"
        $moduleVersion = $newRevision
        $script:m_ModuleVersion = $moduleVersion.ToString()
        Write-Host "New Revision for $m_ModuleName will be $moduleVersion"
        Write-Host "New build means delete everything"
        if ($thisModule -ne $null) {
            #$currentVersion = $thisModule.Version
            $modulePath = $thisModule.ModuleBase
            foreach ($m in $modulePath) {
                Write-Host "Removing $modulePath"
                Remove-Item "$m" -Force -Recurse
            }
            
        }


    }


    Write-Verbose "Removing $m_ModuleName from memory"
    Remove-Module $m_ModuleName -Force -ErrorAction SilentlyContinue

    if ($m_newBuild) {
        Update-ModuleManifest -Path $psdFile -ModuleVersion $script:m_ModuleVersion
    }
    Write-Host "Updated $(Split-Path -Path $psdFile -Leaf) with new Revision"

    $m_OutputPath = Join-Path $m_OutputPath $script:m_ModuleVersion

    Write-Verbose "Output Path: $m_outputPath"

    if (Test-Path -Path $m_OutputPath -PathType Container) {
        Write-Verbose "$m_OutputPath exists, deleting it"
        Remove-Item $m_OutputPath -Recurse -Force
    }
    

    if (-not (Test-Path $m_outputPath )) {
        Write-Verbose "Creating $m_outputPath"
        New-Item -Path $m_outputPath -ItemType Container -Force|Out-Null
    }


    Assert ($(Test-ModuleManifest -Path $psdFile -ErrorAction SilentlyContinue; $?)) -failureMessage "$psdFile does not validate"

    Copy-Item $psdFile -Destination $m_OutputPath
    $buildFolders = get-childitem $m_sourcePath|Where-Object {$_.PSIsContainer}


    Copy-Item $psdFile -Destination $m_OutputPath
    Copy-Item $psmFile -Destination $m_OutputPath
    Copy-Item $prefsFile -Destination $m_OutputPath


    $buildFolders = get-childitem $m_sourcePath|Where-Object {$_.PSIsContainer}

    foreach ($folder in $buildFolders) {
        Write-Verbose "Folder $folder"

        Write-Verbose "Test-Path -Path '$m_outputPath\$($folder.Name)' -PathType Container"
        if (-not (Test-Path -Path "$m_outputPath\$($folder.Name)" -PathType Container)) {
            Write-Verbose "Creating $m_outputPath\$($folder.Name)"
            New-Item -path "$m_outputPath\$($folder.Name)" -ItemType Container |Out-Null

        }

        $thisPsm = Join-Path "$m_outputPath\$($folder.Name)" "Quirky.$($folder.Name).psm1"
        Write-Verbose "Creating file $thisPsm"

        Write-Verbose "Processing Folder $($folder.FullName)"
        $fileList = Get-ChildItem $($folder.FullName) -Exclude Filter*, Alias*

        foreach ($functionFile in $fileList) {
            Write-Verbose "Processing $($functionFile.Fullname)"
            Add-Content  $thisPsm -Value "function $($functionFile.BaseName)(){" 
            Add-Content  $thisPsm -Value $(Get-Content $($functionFile.Fullname)) 
            Add-Content  $thisPsm -Value "}" 
            
        }

        $FilterList = Get-ChildItem $($folder.FullName) |Where-Object {$_.Name -match 'Filter'}
        foreach ($filterFile in $filterList) {
            Write-Verbose "Processing Filter $filterFile.Fullname)"
            Add-Content $thisPSM -Value $(Get-Content $($filterFile.Fullname)) 
        }

        $aliasList = Get-ChildItem $($folder.FullName) |Where-Object {$_.Name -match 'Alias'}
        foreach ($aliasFile in $aliasList) {
            Write-Verbose "Processing Alias $aliasFile.Fullname)"
            Add-Content $thisPSM -Value $(Get-Content $($aliasFile.Fullname)) 
        }

        
    }

    $destinationPSD = Join-Path $m_OutputPath "$m_ModuleName.psd1"
    Write-Verbose "Running Test-MoudleManifest -Path $destinationPSD"
    Assert ($(Test-ModuleManifest -Path "$destinationPSD" -ErrorAction SilentlyContinue; $?)) -failureMessage "$psdFile does not validate"

    Write-Host "Finished Building $m_ModuleName"
}

#Sub Tasks



Task -Name TestProperties -Description "Tests to make sure properies are set" {

    Write-Host "Testing Properites Started"

    Write-Verbose "Testing for Module Name"
    Assert ($m_ModuleName -ne $null) -failureMessage "Can't find Module Name Variable"

    Write-Verbose "Testing for forcing new build"
    Assert ($m_newBuild -ne $null) -failureMessage "Can't find new build variable"

    Write-Verbose "Testing for Build Path"
    Assert ($m_buildPath -ne $null) -failureMessage "Can't find Build Path Variable"

    Write-Verbose "Testing for Code Path $m_sourcePath"
    Assert ($m_sourcePath -ne $null) -failureMessage "Can't find Code Path Variable"

    Write-Verbose "Testing Version $m_ModuleVersion"
    Assert ($m_ModuleVersion -ne $null) -failureMessage "Can't find Version Variable"

    Write-Verbose "Testing Destination Path: $m_outputPath"
    Assert ($m_outputPath -ne $null) -failureMessage "Can't find Destination Path Variable"

    Write-Verbose "Testing old personal functions: $m_PersonalFunctions"
    Assert ($m_PersonalFunctions -ne $null) -failureMessage "Can't find Personal Functions Variable"

    Write-Verbose "Testing for test location"
    Assert ($m_Tests -ne $null) -failureMessage "Can't find test location variable"

    Write-Verbose "Testing for runfirst test tag"
    Assert ($m_firstTestToRunTag -ne $null) -failureMessage "Can't find runfirst test variable"

    Write-Host "Testing Properites Succeeded"

}




Pop-Location