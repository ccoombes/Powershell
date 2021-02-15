$SQLStatus = (Get-Service -Name MSSQLSERVER).Status

if($SQLStatus -ne "Stopped" -or $SQLStatus -ne $null)
{
    BackupSQL
}

if($SQLStatus -eq "Stopped")
{
    Get-Service -Name MSSQLSERVER | Start-Service

    BackupSQL

    Get-Service -Name MSSQLSERVER | Stop-Service
}

function BackupSQL
{
    param(
        $serverName="localhost",
        $backupDirectory="C:\SQLServer\BACKUP\",
        $daysToStoreBackups="30"
    )

    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

    $server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $serverName
    $dbs = $server.Databases
    foreach ($database in $dbs | where { $_.IsSystemObject -eq $False })
    {
        $dbName = $database.Name
 
        $timestamp = Get-Date -format yyyy-MM-dd-HHmmss
        $targetPath = $backupDirectory + "\" + $dbName + "_" + $timestamp + ".bak"
 
        $smoBackup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup")
        $smoBackup.Action = "Log"
        $smoBackup.BackupSetDescription = "Full Backup of " + $dbName
        $smoBackup.BackupSetName = $dbName + " Backup"
        $smoBackup.Database = $dbName
        $smoBackup.MediaDescription = "Disk"
        $smoBackup.Devices.AddDevice($targetPath, "File")
        $smoBackup.SqlBackup($server)
 
        "backed up $dbName ($serverName) to $targetPath"

        Get-ChildItem "$backupDirectory\*.bak" |? { $_.lastwritetime -le (Get-Date).AddDays(-$daysToStoreBackups)} |% {Remove-Item $_ -force }
        "removed all previous backups older than $daysToStoreBackups days"
    }
}