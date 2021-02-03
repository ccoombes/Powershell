$VMs = Get-TagAssignment | Where-Object Tag -like "PatchGroup/Development"
foreach ($vm in $VMs)
{
    New-Snapshot -VM $vm.Entity -Name "xxxxxxxxxxxxxxxx"
}