#load Vmware Module
Add-PSSnapin VMware.VimAutomation.Core

#Change to multi-mode vcenter management
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false

#Get vCenter Server Names
$destVI = 'ipd-wf-vc01.ipmgprint.com.au'

$ipdcreds = Get-Credential

$datacenter = "Warwick Farm"


#Connect to Source vCenter
connect-viserver -server $destVI -credential $ipdcreds -NotDefault:$false


#Create Resource Pools

$cluster = "HPNESXi"
$importedresourcepools = Import-Csv "C:\Temp\ResourcePools-$($datacenter).csv"

foreach ($rp in $importedresourcepools)
{
    Get-Cluster -Name $cluster | New-ResourcePool -Server $destVI -Name $rp.name -CpuSharesLevel $rp.CpuSharesLevel -CpuReservationMhz $rp.CpuReservationMHz -MemSharesLevel $rp.MemSharesLevel -MemReservationGB $rp.MemReservationGB
}

#move vm to resource pool

$importedvmresourcepools = Import-Csv "C:\Temp\vms-with-ResourcePool-$($datacenter).csv"

foreach ($vm in $importedvmresourcepools)
{
    $destrp = Get-ResourcePool -Server $destVI -Location $cluster -Name $vm.ResourcePool
    $a = Get-VM -Server $destVI -Name $vm.VM 

    Move-VM -VM $a -Destination $destrp

}

#Create Folders

$vmfolder = Import-Csv "c:\Temp\Folders-with-FolderPath-$($datacenter).csv" | Sort-Object -Property Path

foreach($folder in $VMfolder){
    $key = @()
    $key =  ($folder.Path -split "\\")[-2]
    if ($key -eq "vm") {
        get-datacenter $datacenter -Server $destVI | get-folder vm | New-Folder -Name $folder.Name
        } else {
        get-datacenter $datacenter -Server $destVI | get-folder vm | get-folder $key | New-Folder -Name $folder.Name 
        }
}

#move the vm's to folders

$VMfolder = @()
$VMfolder = import-csv "c:\Temp\VMs-with-FolderPath-$($datacenter).csv" | Sort-Object -Property Path
foreach($guest in $VMfolder){
    $key = @()
    $key =  Split-Path $guest.Path | split-path -leaf
    Move-VM (get-datacenter $datacenter -Server $destVI  | Get-VM $guest.Name) -Destination (get-datacenter $datacenter -Server $destVI | Get-folder $key) 
}