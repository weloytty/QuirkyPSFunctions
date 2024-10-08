#
# Module manifest for module 'PSGet_Quirky'
#
# Generated by: Bill Loytty
#
# Generated on: 9/3/2024
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'Quirky.psm1'

# Version number of this module.
ModuleVersion = '1.2.0.203'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '58db296f-4b45-4f16-b34c-5741ccc6cab5'

# Author of this module
Author = 'Bill Loytty'

# Company or vendor of this module
CompanyName = 'Bill Loytty'

# Copyright statement for this module
Copyright = '(c) 2015-2018 Bill Loytty All rights reserved.'

# Description of the functionality provided by this module
Description = 'Functions I use all the time (non employer specific)'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Add-TrustedHost', 'Edit-Command', 'Edit-File', 
               'Find-CommandSourceCode', 'Find-Items', 'Format-Environment', 
               'Get-BootTime', 'Get-ChildItemByDate', 'Get-ChildItemBySize', 
               'Get-ChildItemDirectories', 'Get-CommandSource', 'Get-ComputerShares', 
               'Get-CurrentUser', 'Get-DaysUntilChristmas', 'Get-DotNetVersion', 
               'Get-DSCConfigStatus', 'Get-DSCFunctions', 'Get-DSCResourcesInModule', 
               'Get-DSCResourceStatusByPath', 'Get-EnvironmentVariable', 
               'Get-Excuse', 'Get-ExpandedURL', 'Get-FileAttributes', 
               'Get-FileVersion', 'Get-InstalledApplication', 'Get-ModuleFunctions', 
               'Get-NumberOfDays', 'Get-PowershellVersion', 'Get-Properties', 
               'Get-ScriptDirectory', 'Get-WindowsVersion', 'isNumeric', 
               'Remove-WSManShells', 'Set-EnvironmentVariable', 'Set-FileAttributes', 
               'Set-IEFriendlyErrors', 'Set-LocationFromFile', 
               'Set-LocationToModuleFolder', 'Set-LocationToProfileFolder', 
               'Show-ParseStatus', 'Show-WSManShells', 'Start-DebugPowerShell', 
               'Start-ResourceManagerVM', 'Stop-OtherPowershell', 
               'Stop-PendingDSCConfiguration', 'Stop-ResourceManagerVM', 
               'Test-IsAdmin', 'Test-IsRunningAsAdministrator', 'Test-NeedsReboot', 
               'Test-Win32', 'Test-Win64', 'Update-SysInternals', 'Get-TrustedHost', 
               'ConvertTo-UTF8', 'Set-IESecureProtocols', 'Get-DSCConfigDetailsPath', 
               'Get-ConfigStatus', 'Show-DSCConfigurationComplete', 
               'Get-SystemUptime', 'Test-Transcribing', 'Get-WindowsPID', 'Get-VmIp', 
               'Update-ModulesFromNuGet', 'Get-HighestModuleVersion', 'Test-Port', 
               'New-RDPSession', 'Test-PropertyExists', 'Get-DiskSpace', 
               'Get-ModuleVersion', 'Add-WindowsRunCommands', 'Get-ErrorInfo', 
               'Show-FolderDifference', 'Get-LockfileProcess', 'Get-SizeOnDisk', 
               'Import-VSVars', 'Get-ProcessOwner', 'Get-QueueDepth', 
               'Clear-RemoteQueue', 'Get-MSIInformation', 'Show-Calendar', 
               'Test-PwnedPassword', 'Trace-Word', 'Get-ClipboardText', 
               'Set-ClipboardText', 'Test-RegistryValue', 'Set-FileDateToNow', 
               'Format-DiskSize', 'Get-PageFileSize', 'Convert-HexToDec', 
               'Convert-DecToHex', 'Get-UserNameFromSid', 'ConvertFrom-Base26', 
               'ConvertTo-Base26', 'Get-ProcessBitness', 'Get-EnumValues', 
               'Get-UrlEncodedString', 'Get-UrlDecodedString', 'Test-PSRemoting', 
               'Grant-LogOnAsService', 'Get-PEKind', 'Show-WifiPassword'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = 'gcisize', 'gcidate', 'gcidirs', 'edc', 'slm', 'slf', 'slp', 'gms', 'gurl', 'home', 
               'shares', 'sdp', 'isadmin', 'gmf', 'md5', 'killps', 'check', 'fev', 'ppx', 'iesp', 
               'ief', 'whereis', 'gmv', 'cal', 'hex2dec', 'dec2hex', 'gpb', 'urlencode', 
               'urldecode'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
ModuleList = @('Information\Quirky.Information.psm1', 
               'Utility\Quirky.Utility.psm1', 
               'FileSystem\Quirky.FileSystem.psm1', 
               'Users\Quirky.Users.psm1', 
               'Azure\Quirky.Azure.psm1', 
               'DSC\Quirky.DSC.psm1', 
               'Module\Quirky.Module.psm1', 
               'MSMQ\Quirky.MSMQ.psm1')

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

