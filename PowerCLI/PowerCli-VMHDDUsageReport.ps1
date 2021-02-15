$MyCollection = @()

$AllVMs = Get-Datacenter  hpnesx | Get-Folder production | Get-VM hpnmta2 | Get-View

ForEach ($VM in $AllVMs){

 $Details = New-object PSObject
 $Details | Add-Member -Name Name -Value $VM.name -Membertype NoteProperty
 $Details | Add-Member -Name NoCPU -Value ($vm.Config.Hardware.NumCPU * $vm.Config.Hardware.NumCoresPerSocket) -Membertype NoteProperty
 $Details | Add-Member -Name Memory -Value $vm.Config.Hardware.MemoryMB -Membertype NoteProperty
 $Details | Add-Member -Name GuestFamily -Value $VM.Guest.GuestFamily -Membertype NoteProperty
 $Details | Add-Member -Name OS -Value $VM.Guest.GuestFullName -Membertype NoteProperty

 $DiskNum = 0

 Foreach ($disk in $VM.Guest.Disk){


     $Details | Add-Member -Name "Disk$($DiskNum)path" -MemberType NoteProperty -Value $Disk.DiskPath -Verbose
     $Details | Add-Member -Name "Disk$($DiskNum)Capacity(MB)" -MemberType NoteProperty -Value ([math]::Round($disk.Capacity/ 1MB)) -Verbose
     $Details | Add-Member -Name "Disk$($DiskNum)UsedSpace(MB)" -MemberType NoteProperty -Value (([math]::Round($disk.Capacity / 1MB)) - ([math]::Round($disk.FreeSpace / 1MB))) -Verbose
     $Details | Add-Member -Name "Disk$($DiskNum)PercentUsed" -MemberType NoteProperty -Value (((([math]::Round($disk.Capacity / 1MB)) - ([math]::Round($disk.FreeSpace / 1MB))) / (($disk.Capacity/ 1MB)) * 100)) -Verbose
     $DiskNum++

 }

 $MyCollection += $Details

}

$MyCollection | Out-GridView