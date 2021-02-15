Add-PSSnapin VMware.VimAutomation.Core

connect-viserver hps-vcenter

$vmdatastores = Get-Datacenter -Name "hps-esx" | Get-Datastore -name vm*

foreach ($datastore in $vmdatastores) {
    $datastore | Get-VM | move-vm -Location (get-folder -name $datastore.name -Location (Get-Datacenter 'hps-esx'))
}