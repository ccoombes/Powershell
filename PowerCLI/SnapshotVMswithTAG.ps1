<#
.DESCRIPTION
  <Brief description of script>
.NOTES
  Version:        1.0
  Author:         Chris Coombes
  Email:          ccoombes@outlook.com
  Creation Date:  04-02-2021
  Purpose/Change: Initial script development
#>
$VMs = Get-TagAssignment | Where-Object Tag -like "PatchGroup/Development"
foreach ($vm in $VMs)
{
    New-Snapshot -VM $vm.Entity -Name "xxxxxxxxxxxxxxxx"
}