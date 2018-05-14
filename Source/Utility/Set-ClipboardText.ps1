    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        $InputObject
    )

#I got this from https://stackoverflow.com/questions/1567112/convert-keith-hills-powershell-get-clipboard-and-set-clipboard-to-a-psm1-script/15581127#15581127


    # Each input object is converted to a string representation with Out-String,
    # unless it already is a string; the representations of multiple input objects
    # are separated - but not terminated - with a platform-native newline.
    $allText = $sep = ''
    # $Input having a value means that pipeline input was provided.
    #     Note: Since we want to access all pipeline input *at once*,
    #           we do NOT use a process {} block.
    if ($Input) { $InputObject = $Input } 
    foreach ($o in $InputObject) {
      $text = if ($o -is [string]) { $o } else { $o | Out-String }
      $allText += $sep + $text
      if (-not $sep) { $sep = [Environment]::NewLine }
    }

    if ($PSVersionTable.PSEdition -eq 'Desktop') { # *Windows* PowerShell

        if ($PSVersionTable.PSVersion -ge [version] '5.1.0') { # Ps*Win* v5.1+ now has Get-Clipboard / Set-Clipboard cmdlets.
          Set-Clipboard -Value $allText
        } else {
          Add-Type -AssemblyName System.Windows.Forms
          if ([threading.thread]::CurrentThread.ApartmentState.ToString() -eq 'STA') {
              # -- STA mode: we can use [Windows.Forms.Clipboard] directly.
              Write-Verbose "STA mode: Using [Windows.Forms.Clipboard] directly."
              if ($allText.Length -eq 0) { $AllText = "`0" } # Strangely, SetText() breaks with an empty string, claiming $null was passed -> use a null char.
              # To be safe, we explicitly specify that Unicode (UTF-16) be used - older platforms may default to ANSI.
              [System.Windows.Forms.Clipboard]::SetText($allText, [System.Windows.Forms.TextDataFormat]::UnicodeText)

          } else {
              # -- MTA mode: Since the clipboard must be accessed in STA mode, we use a [System.Windows.Forms.TextBox] instance to mediate.
              Write-Verbose "MTA mode: Using a [System.Windows.Forms.TextBox] instance for clipboard access."
              if ($allText.Length -eq 0) {
                  # !! This approach cannot set the clipboard to an empty string: the text box must
                  # !! must be *non-empty* in order to copy something. A null character doesn't work.
                  # !! We use the least obtrusive alternative - a newline - and issue a warning.
                  $allText = "`r`n"
                  Write-Warning "Setting clipboard to empty string not supported in MTA mode; using newline instead."
              }
              $tb = New-Object System.Windows.Forms.TextBox
              $tb.Multiline = $true
              $tb.Text = $allText
              $tb.SelectAll()
              $tb.Copy()
          }
      }

    } else { # PowerShell *Core*

      # No native PS support for writing to the clipboard ->
      # external utilities must be used.

      # To prevent adding a trailing \n, which PS inevitably adds when sending
      # a string through the pipeline to an external command, use a temp. file,
      # whose content can be provided via native input redirection (<)
      $tmpFile = [io.path]::GetTempFileName()

      # Determine the encoding: Unix platforms need UTF8, whereas
      # Windows's clip.exe needs UTF-16LE - both in *BOM-less* form.
      if ($env:OS -eq 'Windows_NT') { 
        # clip.exe on Windows only works as expected with non-ASCII characters
        # with UTF-16LE encoding.
        # Unfortunately, it invariably treats the BOM as *data* too, so 
        # we cannot use 'Set-Content -Enocding Unicode' and must use a 
        # BOM-less encoding via the .NET Framework. 
        [io.file]::WriteAllText($tmpFile, $allText, [System.Text.UnicodeEncoding]::new($false, $false))
      } else { 
        # PowerShell's UTF8 encoding invariably creates a file WITH BOM
        # so we use the .NET Framework, whose default is BOM-*less* UTF8.
        [IO.File]::WriteAllText($tmpFile, $allText)
      }

      if ($env:OS -eq 'Windows_NT') {
        Write-Verbose "Windows: using clip.exe"
        cmd /c clip.exe '<' $tmpFile
      } elseif ((uname) -eq 'Darwin') {
        Write-Verbose "macOS: Using pbcopy."
        bash -c "pbcopy < '$tmpFile'"
      } else {
        Write-Verbose "Linux: trying xclip -sel clip"        
        bash -c "xclip -sel clip < '$tmpFile'"
      }

      Remove-Item $tmpFile 

  }
