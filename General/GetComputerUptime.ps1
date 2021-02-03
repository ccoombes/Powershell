<#
.DESCRIPTION
  Get the uptime of a remote domain joined windows PC
.NOTES
  Version:        1.0
  Author:         Chris Coombes
  Email:          ccoombes@outlook.com
  Creation Date:  01-01-2021
  Purpose/Change: Initial script development
#>

$computer = "."
$lastboottime = (Get-WmiObject -Class Win32_OperatingSystem -computername $computer).LastBootUpTime
$sysuptime = (Get-Date) – [System.Management.ManagementDateTimeconverter]::ToDateTime($lastboottime)
$myHashtable = @{
    ComputerName = $computer 
    Uptime = [string]$sysuptime.days+“ Days ”+$sysuptime.hours+“ Hours ”+$sysuptime.minutes+“ Minutes"
}
New-Object psobject -prop $myHashtable