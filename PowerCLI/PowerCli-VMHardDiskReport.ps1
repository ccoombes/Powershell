Add-PSSnapin VMware.VimAutomation.Core

connect-viserver hpsvcenter

$vms = get-cluster hpnesxi | get-vm | where powerstate -match poweredon

$guest = foreach ($vm in $vms) {

    $VMHardDisks = $vm | Get-HardDisk

    foreach ($VMHD in $VMHardDisks) {

        $props = [Ordered]@{
            Name = $vm.name
            Folder = $VM.Folder.Name
            ResourcePool = $vm.ResourcePool
            AllocatedMemory = $vm.MemoryGB
            CPU = $vm.NumCpu
            OS = $vm.Guest.OSFullName
            HDCount = $VMHardDisks.count
            HDSize =  [decimal]::round($VMHD.CapacityGB)
            HDPersistance = $VMHD.Persistence
            HDType = $vmhd.StorageFormat
            HDLocation = $VMHD.Filename
        }

         new-object psobject -Property $props 
    }
  
}

$guest | Export-CSV -Path C:\Temp\vmhdd.csv