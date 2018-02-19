#
# PersonalFunctions.Preferences.ps1
#
#
#  This can be placed either in the root
#  of the module folder OR
#  in the same place as your profile (i.e.)
#  Split-Path $PROFILE -Parent
#
#
#  Values are:
#  ShowModuleLoadInfo   = Shows timing information
#                         when the module loads.
#
#  ShowStartupDebugSpew = Shows debug info about the
#                         startup. Useful when things
#                         don't load properly
#
#  ModulesToImport      = Turn off modules you don't want
#                         (Like utility has some stuff that
#                          requires PS5, so you may want to
#                          disable that)
#  EditorCommand       =  Which editor you want to use
#                         defaults to notepad if nothing
#                         is here.  Use code.cmd if you want
#                         to use VS Code.
#
#  AzureSubscription   =  The name of your Azure subscription
#                         for use in the Azure module
#
#  SysinternalsDir     =  Where you put Sysinternals, for use
#                         with Get-LatestSysinternals
#
#

@{
    ShowModuleLoadInfo   = $true
    ShowStartupDebugSpew = $true

    ModulesToImport      = @{
        Information = $true
        FileSystem  = $true
        Utility     = $true
        Users       = $true
        DSC         = $true
        Azure       = $true
        Module      = $true
        MSMQ        = $true
    }

    EditorCommand        = 'code.cmd'
    AzureUserName        = 'put your azure username here (thisuser@example.com)'
    AzureSubscription    = 'Put the name of your azure subscription here'
    SysinternalsDir      = "$env:LOCALAPPDATA\Programs"
}
