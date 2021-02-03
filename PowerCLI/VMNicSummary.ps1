#vm summarry with nic
Get-View -ViewType VirtualMachine -Filter @{'Runtime.PowerState'='poweredOn'} | Select Name,                                   
@{N='IP';E={[string]::Join('|',($_.Guest.net.ipAddress))}},
@{N='DNS';E={[string]::Join('|',($_.Guest.IpStack.DnsConfig.IpAddress))}},
@{N='Network';E={[string]::Join('|',($_.guest.net.network))}},
@{N='Network Adapter';E={[string]::Join('|',($_.Config.Hardware.Device  |  Where {$_ -is [VMware.Vim.VirtualEthernetCard]} | ForEach {$_.GetType().Name.Replace('Virtual','')}))}} | ft