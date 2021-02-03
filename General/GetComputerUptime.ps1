$computer = "pmpdc-1.pmplimited.com.au"
$lastboottime = (Get-WmiObject -Class Win32_OperatingSystem -computername $computer -credential $credential).LastBootUpTime
$sysuptime = (Get-Date) – [System.Management.ManagementDateTimeconverter]::ToDateTime($lastboottime)
$myHashtable = @{
    ComputerName = $computer 
    Uptime = [string]$sysuptime.days+“ Days ”+$sysuptime.hours+“ Hours ”+$sysuptime.minutes+“ Minutes"
}
New-Object psobject -prop $myHashtable