#load Vmware Module
Add-PSSnapin VMware.VimAutomation.Core

#Change to multi-mode vcenter management
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false

#Get vCenter Server Names
$sourceVI = 'hpsvcenter.hps.local'

$hpncreds = Get-Credential

$datacenter = "Warwick Farm"

#Connect to Source vCenter
connect-viserver -server $sourceVI -credential $hpncreds


filter Get-FolderPath {
    $_ | Get-View | % {
        $row = "" | select Name, Path
        $row.Name = $_.Name

        $current = Get-View $_.Parent
        $path = $_.Name
        do {
            $parent = $current
            if($parent.Name -ne "vm"){$path = $parent.Name + "\" + $path}
            $current = Get-View $current.Parent
        } while ($current.Parent -ne $null)
        $row.Path = $path
        $row
    }
}

## Export Folders

$report = @()
$report = get-datacenter $datacenter -Server $sourceVI| Get-folder vm | get-folder | Get-Folderpath
        ##Replace the top level with vm
        foreach ($line in $report) {
        $line.Path = ($line.Path).Replace($datacenter + "\","vm\")
        }
$report | Export-Csv "c:\Temp\Folders-with-FolderPath-$($datacenter).csv" -NoTypeInformation

##Export VM Folder Location

$report = @()
$report = get-datacenter $datacenter -Server $sourceVI| get-vm | Get-Folderpath

$report | Export-Csv "c:\Temp\vms-with-FolderPath-$($datacenter).csv" -NoTypeInformation

#Export Resource Pool Config


$resourcepools = get-datacenter $datacenter -Server $sourceVI| get-vm | Get-ResourcePool
$resourcepools | Export-Csv "c:\Temp\ResourcePools-$($datacenter).csv" -NoTypeInformation

#Export VM Resource Pool Location

$virtualmachines = get-datacenter $datacenter -Server $sourceVI| get-vm 

$report = foreach ($vm in $virtualmachines)
{
    $RP = $vm | Get-ResourcePool

    New-Object PSObject -Property @{
        VM = $vm.name
        ResourcePool = $rp.name
    }
}

$report | Export-Csv "c:\Temp\vms-with-ResourcePool-$($datacenter).csv" -NoTypeInformation

