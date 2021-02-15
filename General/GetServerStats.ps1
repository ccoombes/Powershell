$computers = 'cdcfile-1.pmplimited.com.au','cdcdsql.pmplimited.com.au','pmpbfr-2.pmplimited.com.au','jdesql-1.pmplimited.com.au'

#$creds = (Get-Credential)

$output = ''

$output = Foreach ($Computer in $Computers)
{
    $AllDisk = Get-WmiObject Win32_DiskDrive -ComputerName $Computer -Credential $creds | % {
       $disk = $_
       $partitions = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} WHERE AssocClass=Win32_DiskDriveToDiskPartition”
       Get-WmiObject -Query $partitions -ComputerName $Computer -Credential $creds| % {
            $partition = $_
            $drives = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} WHERE AssocClass = Win32_LogicalDiskToPartition"
            Get-WmiObject -Query $drives -ComputerName $Computer -Credential $creds| % {
                New-Object -Type PSCustomObject -Property @{
                    Disk        = $disk.DeviceID
                    DiskSize    = $disk.Size
                    DiskModel   = $disk.Model
                    Partition   = $partition.Name
                    RawSize     = $partition.Size
                    DriveLetter = $_.DeviceID
                    VolumeName  = $_.VolumeName
                    Size        = $_.Size
                    FreeSpace   = $_.FreeSpace
                }
            }
        }
    }

    $SANTotalDisk_GB = (($AllDisk | where diskmodel -like *power*).Size | Measure-Object -Sum).Sum
    $SANFreeSpace_GB = (($AllDisk| where diskmodel -like *power*).FreeSpace | Measure-Object -Sum).Sum
    $SANUsedSpace_GB = $SANTotalDisk_GB - $SANFreeSpace_GB

    $LOCALTotalDisk_GB = (($AllDisk | where diskmodel -notlike *power*).Size | Measure-Object -Sum).Sum
    $LOCALFreeSpace_GB = (($AllDisk | where diskmodel -notlike *power*).FreeSpace | Measure-Object -Sum).Sum
    $LOCALUsedSpace_GB = $LOCALTotalDisk_GB - $LOCALFreeSpace_GB
    
    $TotalSize_GB =  ((Get-WmiObject Win32_Volume -Filter "DriveType='3'" -ComputerName $Computer -Credential $creds).Capacity | measure-object -sum).sum
    $FreeSpace_GB =  ((Get-WmiObject Win32_Volume -Filter "DriveType='3'" -ComputerName $Computer -Credential $creds).FreeSpace | measure-object -sum).sum
    $UsedSpace_GB = $TotalSize_GB - $FreeSpace_GB

    $OperatingSystem = Get-WmiObject win32_OperatingSystem -computer $computer -Credential $creds
    $FreeMemory = $OperatingSystem.FreePhysicalMemory
    $TotalMemory = $OperatingSystem.TotalVisibleMemorySize
    $MemoryUsed = $TotalMemory - $FreeMemory 

    $OS = (gwmi win32_operatingsystem -computer $computer -Credential $creds).Caption
    $Model = (gwmi win32_computersystem -computer $computer -Credential $creds).Model
    $TotalCPU = (Get-WmiObject –class Win32_processor -ComputerName $Computer -Credential $creds).Count
    $TotalCPUCores = ((Get-WmiObject –class Win32_processor -ComputerName $Computer -Credential $creds).NumberOfCores | Measure-Object -Sum).sum

    $LicenseInfo = Get-WmiObject SoftwareLicensingProduct -ComputerName $Computer -Credential $creds | Where-Object { $_.PartialProductKey -and $_.ApplicationID -eq "55c92734-d682-4d71-983e-d6ec3f16059f" } | Select-Object PartialProductKey, Description, LicenseStatus
    If ($LicenseInfo.ProductKeyChannel) { $LicenseType = $LicenseInfo.ProductKeyChannel} 
    Else {$LicenseType = $LicenseInfo.Description.Split(",")[1] -replace " channel", "" -replace "_", ":" -replace " ", ""} 

    $props = [ordered]@{
        Name = $Computer
        OS = $OS
        License=$LicenseType
        Model= $Model
        'TotalCPU' = $TotalCPU
        'TotalCPUCores' = $TotalCPUCores
        'TotalMemory(GB)' = ([Math]::Round($TotalMemory /1MB,0))
        'UsedMemory(GB)' = ([Math]::Round($MemoryUsed /1MB,0))
        'TotalDisk(GB)' = ([Math]::Round($TotalSize_GB /1GB,0))
        'UsedDisk(GB)' = ([Math]::Round($UsedSpace_GB /1GB,0))
        'LOCALTotalDisk(GB)' = ([Math]::Round($LOCALTotalDisk_GB /1GB,0))
        'LOCALUsedDisk(GB)' = ([Math]::Round($LOCALUsedSpace_GB /1GB,0))
        'SANTotalDisk(GB)' = ([Math]::Round($SANTotalDisk_GB /1GB,0))
        'SANUsedDisk(GB)' = ([Math]::Round($SANUsedSpace_GB /1GB,0))
        
    }

    New-Object PSObject -Property $props
}

$output | fl