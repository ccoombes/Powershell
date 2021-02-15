$pgs = Get-VMHost ipd-wf-esxi01.ipmgprint.com.au | Get-VirtualSwitch -Name vSwitch2 | Get-VirtualPortGroup

$destvswitch = Get-VMHost ipd-wf-esxi03.ipmgprint.com.au | Get-VirtualSwitch -Name "vSwitch2"

foreach ($pg in $pgs)
{
    $destvswitch | New-VirtualPortGroup -Name $pg.Name -VLanId $pg.VLanId
}