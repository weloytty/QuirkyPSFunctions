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

Include ".\buildFunctions.ps1"

Properties {

    $m_moduleName = "Quirky"
    $m_newBuild = $true
    $m_buildPath = $psake.build_script_file

    $m_sourceFolder = "Source"
    $m_outputFolder = "Build"

    $m_buildParent = $(Split-Path $m_buildPath -Parent)

    $m_sourcePath = $(Split-Path $m_buildParent -Parent)
    $m_version = "1.1.0.0"
    $m_fileList = @(
        "Quirky.psm1",
        "Quirky.psd1",
        "Quirky.Preferences.ps1",
        "FileSystem\Quirky.FileSystem.psm1",
        "Utility\Quirky.Utility.psm1",
        "Information\Quirky.Information.psm1",
        "Users\Quirky.Users.psm1",
        "Azure\Quirky.Azure.psm1",
        "DSC\Quirky.DSC.psm1",
        "Module\Quirky.Module.psm1",
        "O365\Quirky.O365.psm1",
        "O365\AD\Quirky.O365.AD.psm1",
        "O365\Exchange\Quirky.O365.Exchange.psm1"
    )

    $m_PersonalFunctions = "PersonalFunctions"
    $m_firstTestToRunTag = @( "runfirst")
    #$m_destinationPath = $(Join-Path $(Split-Path $PROFILE -Parent) "Modules\$m_ModuleName")
    #$m_destinationPath = Join-Path "$($Env:ProgramFiles)\WindowsPowerShell\Modules" "\Quirky"
    $m_Tests = $(Join-Path $m_sourcePath "Tests")

}

$scriptPath = Split-Path $myinvocation.MyCommand.Source
Push-Location 
Set-Location $scriptPath
$m_destinationPath = Join-Path "$scriptpath" "Output"


FormatTaskName "-------- {0} --------"


#Main tasks

Task default -depends PreBuild
Task Full -depends TestProperties, PreBuild, Deploy, Test
Task CleanBuild -depends TestProperties, Clean, PreBuild, Deploy, Test


Task Clean -depends TestProperties -Description "Cleans out the destination module folder" {

    Write-Host "Starting Task Clean"
    if (Test-Path $m_destinationPath -PathType Container) {
        if ((Get-Module -Name $m_ModuleName -ErrorAction SilentlyContinue) -ne $null) {
            Remove-Module $m_ModuleName -Force
        }

        Write-Verbose "Removed Module"
        Assert ((Get-Module $m_ModuleName) -eq $null) -failureMessage "$m_ModuleName not unloaded"

        Write-Verbose "Removing files from $m_destinationPath"
        $toDelete = Get-ChildItem $m_destinationPath
        foreach ($deleteFolder in $toDelete) {
            Write-Verbose "Remove-Item $($deleteFolder.FullName) -recurse -force"
            #remove-item $toDelete
            Assert (-not (Test-Path $($deleteFolder.FullName) -PathType Container)) -failureMessage "$m_DestinationPath not deleted"
        }

    } else {
        Write-Verbose "$m_destinationPath not available"
    }
    Write-Host "Task Clean Succeeded"

}

Task -Name Build -depends TestProperties -Description "Builds PSM1 files from PS1"
{

$buildFolders = get-childitem Source|Where-Object {$_.PSIsContainer}
foreach($folder in $buildFolders)
{
  Write-Verbose "Folder $folder"
  $psmFile = Join-Path "$($folde.FullName)" "$($folder.Name).psm1"
  Write-Verbose "Creating file $psmFile"

Write-Verbose "Running Get-ChildItem $($folder.FullName)|Get-Content|Set-Content $psmFile"
#Get-ChildItem $folder|Get-Content|Set-Content "$psmFile"

}



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

Task -Name Deploy -depends PreBuild -Description "Deploys the files" {

    $psdFile = Join-Path $m_sourcePath "$m_ModuleName.psd1"
    Write-Host "$PSDFile"

    $moduleVersion = $m_Version.ToString()

    Write-Host "Starting Deployment"

    Write-Host "PSD File: $psdFile"
    Write-Host "Module  : $m_ModuleName"
    $currentVersion = New-Object -TypeName System.Version -ArgumentList $m_Version
    $thisModule = (Get-Module -Name $m_ModuleName -ListAvailable -ErrorAction SilentlyContinue)
    Write-Host "Build preset is version $($m_Version)"
    if ($thisModule -ne $null) {
        Write-Host "Using version from $m_ModuleName"
        $currentVersion = $thisModule.Version

    }
    $moduleVersion = $currentVersion.ToString()
    if (Test-Path $psdFile -PathType Leaf) {
        Write-Host "Updating version from $(Split-Path $psdFile -Parent)"
        $newCurrentVersion = Test-ModuleManifest -Path $psdFile|Select -ExpandProperty Version
        $currentVersion = $newCurrentVersion
    }

    Write-Host "Loading $m_ModuleName"

    $modulePath = Join-Path "$($Env:ProgramFiles)\WindowsPowerShell\Modules)" "\Quirky"



    Write-Host "Current Version in manifest is $currentVersion"
    $moduleVersion = $currentVersion.ToString()
    if ($m_newBuild) {

        $newRevision = "$($currentVersion.Major).$($currentVersion.Minor).$($currentVersion.Build).$([int]$currentVersion.Revision +1)"
        $moduleVersion = $newRevision
        $m_Version = $moduleVersion.ToString()
        Write-Host "New Revision for $m_ModuleName will be $moduleVersion"
        Write-Host "New build means delete everything"
        if ($thisModule -ne $null) {
            #$currentVersion = $thisModule.Version
            $modulePath = $thisModule.ModuleBase
            Write-Host "Removing $modulePath"
            Remove-Item $modulePath -Force -Recurse
        }


    }


    Write-Verbose "Removing $m_ModuleName from memory"
    Remove-Module $m_ModuleName -Force -ErrorAction SilentlyContinue

    Update-ModuleManifest -Path $psdFile -ModuleVersion $moduleVersion
    Write-Host "Updated $(Split-Path -Path $psdFile -Leaf) with new Revision"





    Assert ($(Test-ModuleManifest -Path $psdFile -ErrorAction SilentlyContinue; $?)) -failureMessage "$psdFile does not validate"

    foreach ($fileName in $m_fileList) {

        $source = Join-Path $m_sourcePath $fileName

        $basePath = Split-Path $m_DestinationPath -Parent
        if (-not (Test-Path $basePath -PathType Container)) {
            Write-Verbose "Creating $basePath"
            New-Item -Path "$basePath" -ItemType Directory -Force | Out-Null
        }


        $finalDestinationFolder = Join-Path $m_destinationPath $moduleVersion
        # Write-Host "Deployment folder is $finalDestinationFolder"
        $destination = Join-Path $finalDestinationFolder $fileName


        $destinationParent = Split-Path $destination -Parent
        if (-not (Test-Path -Path $destinationParent -PathType Container)) {
            Write-Verbose "Creating $DestinationParent"
            New-Item -Path "$destinationParent" -ItemType Directory -Force | Out-Null
        }

        $sourceMD5 = (Get-MD5ChecksumPsake -File $source).HashString
        $destinationMD5 = ""
        if (Test-Path -Path $destination) {
            $destinationMD5 = (Get-MD5ChecksumPsake -File $destination).HashString
        }

        if ($sourceMD5 -ne $destinationMD5) {
            Write-Verbose "Copying: $fileName`n to $destination"
            Write-Verbose $Source
            Write-Verbose $Destination
            Copy-Item -Path "$source" -Destination "$destination" -Force
        } else { Write-Verbose "Skipping $fileName.  MD5 match" }

    }
    $destinationPSD = Join-Path $finalDestinationFolder "$m_ModuleName.psd1"
    Write-Verbose "Running Test-MoudleManifest -Path $destinationPSD"
    Assert ($(Test-ModuleManifest -Path "$destinationPSD" -ErrorAction SilentlyContinue; $?)) -failureMessage "$psdFile does not validate"

    Write-Host "Finished Deploying $m_ModuleName"
}

#Sub Tasks

Task -Name RemoveOld -Description "Deletes Old Version of Quirky before name change" -depends TestProperties {
    Write-Host "Testing for old module (Personal Functions)"
    $module = $(Get-Module $m_PersonalFunctions -ListAvailable)
    if ($module -ne $null) {
        if ((Get-Module -Name $($module.Name)) -ne $null) {
            Write-Verbose "Removing $($module.Name) from memory"
            Remove-Module -Name $($module.Name) -Force
        }

        $modulePath = $module.ModuleBase
        Write-Verbose "Testing for $modulePath"
        if (Test-Path $modulePath -PathType Container) {
            Write-Verbose "Deleting $modulePath"
            Remove-Item -Path $modulePath -Force -Recurse
        }

        Assert (-not (Test-Path -Path $modulePath -PathType Container)) -failureMessage "$modulePath not deleted"
    }
    Write-Host "Testing for old module (Personal Functions) Succeeded"
}


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

    Write-Verbose "Testing Version $m_Version"
    Assert ($m_Version -ne $null) -failureMessage "Can't find Version Variable"

    Write-Verbose "Testing Destination Path: $m_DestinationPath"
    Assert ($m_DestinationPath -ne $null) -failureMessage "Can't find Destination Path Variable"

    Write-Verbose "Testing old personal functions: $m_PersonalFunctions"
    Assert ($m_PersonalFunctions -ne $null) -failureMessage "Can't find Personal Functions Variable"

    Write-Verbose "Testing for test location"
    Assert ($m_Tests -ne $null) -failureMessage "Can't find test location variable"

    Write-Verbose "Testing for runfirst test tag"
    Assert ($m_firstTestToRunTag -ne $null) -failureMessage "Can't find runfirst test variable"

    Write-Host "Testing Properites Succeeded"

}

Task -Name PreBuild -Description "Makes sure all files are present and valid" -depends TestProperties {

    Write-Host "Prebuild Starting"
    if (-not (Test-Path -Path $m_DestinationPath -PathType Container)) {
        New-Item -Path $m_DestinationPath -ItemType Container -Force | Out-Null
    }
    foreach ($file in $m_FileList) {
        $filePath = $(Join-Path $m_sourcePath $file)
        Write-Verbose "Testing for $filePath"
        if (-not (Test-Path -Path $(Split-Path -Path $filePath -Parent))) {
            Write-Verbose "Creating Path $(Split-Path -Path $filePath -Parent)"
            New-Item -Path $(Split-Path -Path $filePath -Parent) -ItemType Container -Force | Out-Null
        }
        Assert ($(Test-Path -Path $filePath -PathType Leaf)) -failureMessage "Path $filePath does not exist"
    }

    Assert ($(Test-Path -Path $m_DestinationPath)) -failureMessage "Path $m_destinationPath does not exist"
    Write-Host "Testing Destination Folder"
    Write-Verbose "Destination Path $m_DestinationPath"

    Assert ($(Test-Path $m_destinationPath -PathType Container)) -failureMessage "Can't find buildPath"

    $psdFile = Join-Path $m_sourcePath "$m_ModuleName.psd1"
    Assert ($(Test-Path $psdFile -PathType Leaf)) -failureMessage "Can't find PSD $psdFile"
    Assert ($(Test-ModuleManifest -Path $psdFile)) -failureMessage "$(split-path $psdFile -Leaf) does not validate"

    Write-Host "Pre-Build Succeeded"

}



Pop-Location