Add-PSSnapin VMware.VimAutomation.Core

connect-viserver hpsvcenter

$start = (get-date).adddays(-30)
$finish = get-date

$vms = get-cluster hpnesxi | get-vm | where powerstate -match poweredon

$output = foreach ($vm in $vms) {

    $stats = get-stat -Entity $vm -Stat "mem.consumed.average" -Start $start -Finish $finish

    $consumed = [int]($stats | Measure-Object -Property Value -Average).Average / 1024

    $guest = new-object psobject -Property @{
        Name = $vm.name
        ConsumedMemory = $consumed
        AllocatedMemory = $vm.MemoryMB
        Consumed = ($consumed / $vm.MemoryMB) * 100
    }
    $guest
}