$vmhosts = "hpnesxi-1.hps.local","hpnesxi-2.hps.local","hpnesxi-3.hps.local"
#$vmhosts = "hpnesxi-4.hps.local"
 
foreach ($a in $vmhosts)
{
    $vSwitch = Get-VMHost $a | Get-VirtualSwitch -Name "vSwitch3"
    #$vSwitch = Get-VMHost $a | Get-VirtualSwitch -Name "vSwitch4"  
    $vSwitch | New-VirtualPortGroup -VLanId 2 -Name "IPD-WF-WIFIMGMT"
}