[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
    [System.IO.FileInfo]$assemblies
)

process {

    #https://docs.microsoft.com/en-us/dotnet/api/system.reflection.portableexecutablekinds?view=net-5.0

    #FIELDS
    #ILOnly	        1	The executable contains only Microsoft intermediate language (MSIL), 
    #                   and is therefore neutral with respect to 32-bit or 64-bit platforms.
    
    #NotAPortableExecutableImage	0	The file is not in portable executable (PE) file format.
    
    #PE32Plus	    4   The executable requires a 64-bit platform.
    
    #Preferred32Bit	16	The executable is platform-agnostic but should be run on a 32-bit platform 
    #                   whenever possible.
    
    #Required32Bit	2	The executable can be run on a 32-bit platform, or in the 32-bit Windows on 
    #                   Windows (WOW) environment on a 64-bit platform.
    
    #Unmanaged32Bit	8	The executable contains pure unmanaged code.


    foreach ($assembly in $assemblies) {
        $ass = Get-Item $assembly


        $peKinds = New-Object Reflection.PortableExecutableKinds
        $imageFileMachine = New-Object Reflection.ImageFileMachine

        $a = [Reflection.Assembly]::LoadFile($ass.Fullname)
        $a.ManifestModule.GetPEKind([ref]$peKinds, [ref]$imageFileMachine)


        $o = New-Object System.Object
        $o | Add-Member -type NoteProperty -Name File -Value $assembly
        $o | Add-Member -type NoteProperty -Name PEKind -Value $peKinds
        Write-Output $o
    }
}