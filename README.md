# QuirkyPSFunctions

Functions I use every day that aren't employer or customer specific. 

When I end up doing something more than once I put it in here, so I will always remember where it is.  They're not at all ready for prime time, they just work for me (more or less).  I also add stuff I see on the internet, I've tried to comment the source of each I borrowed.

(some of them, like the Add-User type functions, are obsolete (finally!), but I leave them in because I have to deal with Windows Server 2008 sometimes)

People ask why I don't put this on psgallery or something like that, and the reason is simple:  This is a grab bag of stuff I use, that Works For Me(tm).  Some have tests, most dont, and there are more than a few in there that flat don't work at all.  


The functions are broken out into different areas

*Azure*

Start-ResourceManagerVM
Stop-ResourceManagerVM

*DSC*

Get-DSCConfigDetailsPath
Get-DSCConfigStatus
Get-DSCFunctions
Get-DSCResourcesInModule
Remove-WSManShells
Show-DSCConfigurationComplete
Show-WSManShells
Stop-PendingDSCConfiguration

*File System*

Get-ChildItemByDate
Get-ChildItemBySize
Get-ChildItemDirectories
Get-ComputerDiskSpace
Get-FileAttributes
Get-FileVersion
Get-LocalFileName
New-QShare
Set-FileAttributes
Set-LocationFromFile

*Information*

Find-Items
Format-Environment
Get-BootTime
Get-ComputerShares
Get-DotNetVersion
Get-EnumValues
Get-InstalledApplication
Get-PowershellVersion
Get-SystemUptime
Get-WindowsPID
Get-WindowsVersion

*Module*

Edit-Command
Find-CommandSourceCode
Get-CommandSource
Get-HighestModuleVersion
Get-ModuleFunctions
Get-ModuleVersion
Get-Properties
Get-ScriptDirectory
Set-LocationToModuleFolder
Update-ModulesFromNuGet

*Users*

Add-QDomainUserToLocalGroup
Get-CurrentUser
Get-EnvironmentVariable
Get-QLocalUser
Get-QLocalUsers
New-QLocalUser

*Utility*

Add-TrustedHost
Add-WindowsRunCommands
ConvertTo-UTF8
Edit-File
Filter-IsNumeric
Find-Items
Format-QXml (PSCX's works better)
Get-DaysUntilChristmas
Get-ErrorInfo
Get-Excuse
Get-ExpandedURL
Get-MD5Checksum
Get-NumberOfDays
Get-TrustedHost
Get-VmIp
New-RDPSession
Set-EnvironmentVariable
Set-IEFriendlyErrors
Set-IESecureProtocols
Set-LocationToProfileFolder
Show-ParseStatus
Start-DebugPowerShell
Stop-OtherPowershell
Test-IsAdmin
Test-NeedsReboot
Test-Port
Test-PropertyExists
Test-Transcribing
Test-Win32
Test-Win64
Update-SysInternals


