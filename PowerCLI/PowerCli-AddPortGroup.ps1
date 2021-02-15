$vmhost = "hpnesxi-4.hps.local"

Get-Cluster "HPNESXi"  | Get-VMHost $vmhost | Get-VirtualSwitch -Name "vSwitch4" | New-VirtualPortGroup -Name “FACTORY” -VLanId 1001

Get-Cluster "HPNESXi"  | Get-VMHost $vmhost | Get-VirtualSwitch -Name "vSwitch4" | New-VirtualPortGroup -Name “ADMIN” -VLanId 20
