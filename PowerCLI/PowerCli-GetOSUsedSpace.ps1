ForEach ($VM in Get-Datacenter "Lidcombe" | Get-ResourcePool -Name "Tier1-IPMGMIS" | Get-VM)
{

    $used = 0


    ForEach ($Drive in $VM.Extensiondata.Guest.Disk) 
    {
        #Calculations 

        $Freespace = [math]::Round($Drive.FreeSpace / 1MB)

        $Capacity = [math]::Round($Drive.Capacity/ 1MB)

        $Used = $used + ($Capacity - $Freespace)
    }

    $a = [math]::Round($Used/1024,2)

    Write-Output $vm.name $a

}
