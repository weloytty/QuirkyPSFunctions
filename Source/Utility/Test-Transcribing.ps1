#I found this on the internet somewhere and I'm not all that sure it actually works -- it seems to
#in trivial cases, but not when I have scripts calling scripts.  Should probably revisit

$externalHost = $host.gettype().getproperty("ExternalHost", [reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())

try {
    $externalHost.gettype().getproperty("IsTranscribing", [reflection.bindingflags]"NonPublic,Instance").getvalue($externalHost, @())
} catch {
    #you will also hit this if you're in VSCode's terminal
    Write-Host "This host does not support transcription."
}
