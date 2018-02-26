[CmdletBinding()]
param(
    [ValidateSet(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)]
    [int]$Month = $(Get-Date).Month,
    [int]$Year = $(Get-Date).Year)

process {
    Set-StrictMode -Version Latest
       

    $whichMonth = Get-Date -Month $month -Year $year -Day 1
    $dispMonth = (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($whichMonth.Month)
    $headingText = "$($dispMonth) $($whichMonth.Year)"
    Write-verbose $headingText
        
    $formattedText = " " * $((19 - $($headingText).Length) / 2) + $headingtext
    Write-Host $formattedText
    
    Write-Host "S  M  T  W  R  F  S"
    #how many days in a month?  Go to next month, on the first, subtract a day
    #see what day it is
    $daysInMonth = $($whichMonth.AddMonths(1).AddDays(-1).Day)
    
    $startOffset = [int]$($whichMonth.DayOfWeek) 
    Write-Host $(" " * $($startOffset * 3)) -NoNewLine
    #Write-Verbose "Start Offset = '$startOffset'"
    for ($i = 0; $i -lt $daysInMonth; $i++) {
        $thisDay = $(Get-Date -Month $month -Year $year -Day ($i + 1))
            
        $paddedDay = $("0" + $thisDay.Day).ToString()
        $whatToPrint = $paddedDay.Substring($paddedDay.length - 2)
        
        $dayNum = $([int]$thisDay.DayOfWeek)

        if ($dayNum -eq 6) {
            Write-Host "$whatToPrint "
        } else {
            Write-Host "$whatToPrint " -NoNewLine
        }

    }


}
