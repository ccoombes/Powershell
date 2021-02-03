 #Variables
 $viserver = "vcsa01.internal.georgieandchris.com"
 $vmhosts = ("esxi01.internal.georgieandchris.com",
             "esxi02.internal.georgieandchris.com",
             "esxi03.internal.georgieandchris.com"
            )
 $vSwitch = "vSwitch0"
 
 Get-VirtualSwitch -VMhost $vmhost -Name $vSwitch | New-VirtualPortGroup -Name 'FW (VLAN 1001) - 10.1.1.x' -VlanId '1001'
 Get-VirtualSwitch -VMhost $vmhost -Name $vSwitch | New-VirtualPortGroup -Name 'MODEM (VLAN 1002) - 10.1.2.x' -VlanId '1002'
 Get-VirtualSwitch -VMhost $vmhost -Name $vSwitch | New-VirtualPortGroup -Name 'DMZ (VLAN 1003) - 10.1.3.x' -VlanId '1003'
 Get-VirtualSwitch -VMhost $vmhost -Name $vSwitch | New-VirtualPortGroup -Name 'IOT (VLAN 201) - 192.168.201.x' -VlanId '201'
 Get-VirtualSwitch -VMhost $vmhost -Name $vSwitch | New-VirtualPortGroup -Name 'Server (VLAN 1601) - 172.16.1.x' -VlanId '1601'