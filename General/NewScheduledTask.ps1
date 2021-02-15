$scriptblock = {
    $Action = New-ScheduledTaskAction –Execute "powershell.exe" -Argument "-File \\hps.local\public\Powershell\Scripts\Network\BackupGPO.ps1 -Hidden"
    $Trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek Monday -At 7am
    $Settings = New-ScheduledTaskSettingsSet -Hidden
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings 
    Register-ScheduledTask -TaskName "NetworkGPOBackup" -InputObject $Task -User "hps\hpnautomation" -Password "hannan50%" 
}

Invoke-Command -ComputerName hpnautomation -ScriptBlock $scriptblock