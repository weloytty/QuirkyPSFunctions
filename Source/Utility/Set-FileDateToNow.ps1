[CmdletBinding()]
param([string] $Path)
if(test-path $Path -PathType Leaf)
    {


    Set-ItemProperty -Path $Path -Name LastWriteTime -Value (get-date)
    “File $Path timestamp succesfully updated”
    }
else
    {
    Set-Content -Path ($Path) -Value ($null);
    “File $Path succesfully created”
    }


