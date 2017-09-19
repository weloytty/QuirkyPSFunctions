$externalHost = $host.gettype().getproperty("ExternalHost", [reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())

try {
    $externalHost.gettype().getproperty("IsTranscribing", [reflection.bindingflags]"NonPublic,Instance").getvalue($externalHost, @())
} catch {
    #you will also hit this if you're in VSCode's terminal
    write-warning "This host does not support transcription."
}
