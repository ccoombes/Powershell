$hosts = $portGroup = Get-Cluster hpnesxi | Get-VMHost 

$vmwareNet = foreach ($vhost in $hosts) {
    $virtualSwitch = Get-VirtualSwitch -VMHost $vhost
    foreach ($switch in $virtualSwitch) {
        $portGroups = Get-VirtualPortGroup -VirtualSwitch $switch
        foreach ($portGroup in $portGroups){
            $props = [ordered]@{
                Host = $vhost.Name
                Switch = $portGroup.VirtualSwitchName
                PortGroup = $portGroup.name
                Vlan = $portGroup.VlanId
                
            }
            New-Object psobject -Property $props
        }
    }
}

$vmwareNet