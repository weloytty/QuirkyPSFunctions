[CmdletBinding()] # to support -OutVariable and -Verbose
param()

if ($PSVersionTable.PSEdition -eq 'Desktop') {


    #I got this from https://stackoverflow.com/questions/1567112/convert-keith-hills-powershell-get-clipboard-and-set-clipboard-to-a-psm1-script/15581127#15581127

    # *Windows* PowerShell
    if ($PSVersionTable.PSVersion -ge [version] '5.1.0') {
        # Ps*Win* v5.1+ now has Get-Clipboard / Set-Clipboard cmdlets.
        Get-Clipboard -Format Text
    } else {
        Add-Type -AssemblyName System.Windows.Forms
        if ([threading.thread]::CurrentThread.ApartmentState.ToString() -eq 'STA') {
            # -- STA mode:
            Write-Verbose "STA mode: Using [Windows.Forms.Clipboard] directly."
            # To be safe, we explicitly specify that Unicode (UTF-16) be used - older platforms may default to ANSI.
            [System.Windows.Forms.Clipboard]::GetText([System.Windows.Forms.TextDataFormat]::UnicodeText)
        } else {
            # -- MTA mode: Since the clipboard must be accessed in STA mode, we use a [System.Windows.Forms.TextBox] instance to mediate.
            Write-Verbose "MTA mode: Using a [System.Windows.Forms.TextBox] instance for clipboard access."
            $tb = New-Object System.Windows.Forms.TextBox
            $tb.Multiline = $tru
            $tb.Paste()
            $tb.Text
        }
    }
} else {
    # PowerShell Core
    if ($env:OS -eq 'Windows_NT') {
        # Gratefully adapted from http://stackoverflow.com/a/15747067/45375
        # Note that trying the following directly from PowerShell Core does NOT work,
        #   (New-Object -ComObject htmlfile).parentWindow.clipboardData.getData('text')
        # because .parentWindow is always $null
        $tempFile = [io.path]::GetTempFileName()
        "WSH.Echo(WSH.CreateObject('htmlfile').parentWindow.clipboardData.getData('text'));" | set-content $tempFile
        cscript /nologo /e:JScript $tempFile
        Remove-Item $tempFile
    } elseif ((uname) -eq 'Darwin') {
        pbpaste
    } else {        
        # Note: May work on Ubuntu only, and there only if xclip was
        # installed with: sudo apt install xclip
        xclip -sel clipboard -o
    }
}