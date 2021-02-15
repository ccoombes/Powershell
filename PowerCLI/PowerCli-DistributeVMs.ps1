Add-PSSnapin VMware.VimAutomation.Core

Connect-VIServer hpsvcenter

$ClusterName = "IPD-NP-ESXi"

[array]$Hosts = Get-VMHost -Location $ClusterName
$HostCount = $Hosts.Count

$VMs = Get-VM -Location $ClusterName
$VMs = $VMs | Get-Random -Count $VMs.Count

$Count = 0

ForEach ($VM in $VMs){

$HostNumber = $Count % $HostCount

Write-Host -ForegroundColor Yellow "Moving "$VM" to "$Hosts[$HostNumber]

Move-VM $VM -Destination $Hosts[$HostNumber] -RunAsync
$Count++
}

Disconnect-VIServer hpsvcenter -Force -Confirm:$false