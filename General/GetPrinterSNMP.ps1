$Printers = Import-Csv C:\Temp\RicohPrinters.csv

Function Get-SNMPInfoHC {
    Param (
        [String[]]$PrinterName
    )
    Begin {
        $SNMP = New-Object -ComObject olePrn.OleSNMP
    }
    Process {
        Foreach ($P in $PrinterName) {
            $SNMP.Open($P,"public",2,3000)
            [PSCustomObject][Ordered]@{
                Model       = $SNMP.Get(".1.3.6.1.2.1.25.3.2.1.3.1")
                SN          = $SNMP.Get(".1.3.6.1.2.1.43.5.1.1.17.1")
                Description = $SNMP.Get(".1.3.6.1.2.1.1.1.0")
            }
            $SNMP.Close()
        }
    }
} 


$output = foreach ($Printer in $Printers)
{
    $info = Get-SNMPInfoHC $Printer.IP
    [PSCustomObject][Ordered]@{
        Name = $Printer.Name
        IP = $Printer.IP
        Location = $Printer.Location
        Model = $info.Model
        SN = $info.sn
        Description = $info.Description   
    }
}
   

$output | Export-Csv C:\temp\RicohPrintersAll.csv -NoTypeInformation
