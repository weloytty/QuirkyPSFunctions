<#

.SYNOPSIS
  Powershell script to get file size and size on disk of all files
  in a directory.
  
.DESCRIPTION
  This PowerShell script gets file size and size on disk in bytes
  of all files in a directory.
  
.PARAMETER <path>
   Directory path of the files to check. If this parameter is not
   specified the default value is current directory.
 
.NOTES
  Version:        1.0
  Author:         Open Tech Guides
  Creation Date:  06-Feb-2017
 
.LINK
    www.opentechguides.com
    
.EXAMPLE
  Get-FileSizeOnDisk c:\myfolder

#>
   

param (
 [string]$path='.'
)


$source = @"
 using System;
 using System.Runtime.InteropServices;
 using System.ComponentModel;
 using System.IO;

 namespace Win32
  {
    
    public class Disk {
	
    [DllImport("kernel32.dll")]
    static extern uint GetCompressedFileSizeW([In, MarshalAs(UnmanagedType.LPWStr)] string lpFileName,
    [Out, MarshalAs(UnmanagedType.U4)] out uint lpFileSizeHigh);	
        
    public static ulong GetSizeOnDisk(string filename)
    {
      uint HighOrderSize;
      uint LowOrderSize;
      ulong size;

      FileInfo file = new FileInfo(filename);
      LowOrderSize = GetCompressedFileSizeW(file.FullName, out HighOrderSize);

      if (HighOrderSize == 0 && LowOrderSize == 0xffffffff)
       {
	 throw new Win32Exception(Marshal.GetLastWin32Error());
      }
      else { 
	 size = ((ulong)HighOrderSize << 32) + LowOrderSize;
	 return size;
       }
    }
  }
}

"@

Add-Type -TypeDefinition $source

$result = @()

Get-ChildItem $path | Where-Object { ! $_.PSIsContainer} | Foreach-Object { 
  
    $size = [Win32.Disk]::GetSizeOnDisk($_.FullName)
    $obj = New-Object PSObject
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "File Name" -Value $_.Name
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "Size" -Value $_.Length
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "Size on Disk" -Value $size
    $result += $obj
}

write-output $result 