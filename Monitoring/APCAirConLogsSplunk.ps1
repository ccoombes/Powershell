$Path = "\\hpnsplunk\SplunkLogs"
$filename = "APCAirConLogs.txt"

$RCUnits = '10.100.150.201','10.100.150.202'
$UPSUnits = '10.70.50.3'

$date=(get-date -UFormat "%b %d %Y %T")

$AirConOutput = foreach ($RCUnit in $RCunits){

    $RCUnintName = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $RCUnit "1.3.6.1.4.1.318.1.1.13.3.2.2.1.2")
    $RackInletTemp = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $RCUnit "1.3.6.1.4.1.318.1.1.13.3.2.2.2.7")/10
    $SupplyAirTemp = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $RCUnit "1.3.6.1.4.1.318.1.1.13.3.2.2.2.9")/10
    $flow = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $RCUnit "1.3.6.1.4.1.318.1.1.13.3.2.2.2.22")/100
    $valvePos = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $RCUnit "1.3.6.1.4.1.318.1.1.13.3.2.2.2.20")/10
    $fanspeed = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $RCUnit "1.3.6.1.4.1.318.1.1.13.3.2.2.2.16")/10
    $enterwatertemp = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $RCUnit "1.3.6.1.4.1.318.1.1.13.3.2.2.2.24")/10
    $exitwatertemp = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $RCUnit "1.3.6.1.4.1.318.1.1.13.3.2.2.2.26")/10
    
    $splunkOutput = "$date $RCUnintName : UnitID=$RCUnintName RackTemp=$RackInletTemp SupplyAirTemp=$SupplyAirTemp Flow=$flow ValvePos=$valvePos FanSpeed=$fanspeed EnterWaterTemp=$enterwatertemp ExitWaterTemp=$exitwatertemp"
    $splunkOutput | out-file -FilePath (join-path $path $filename) -append -Encoding utf8
}

$filename = "APCUPSLogs.txt"
$UPSUnits = '10.70.50.3'

$UPSOutput = foreach ($UPS in $UPSUnits){
    $UPSUnitName = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $UPS "1.3.6.1.4.1.318.1.1.1.1.1.2")
    $UPSEstRunTime = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $UPS "1.3.6.1.4.1.318.1.1.1.2.2.3")

    $a = ""
    $b = ""
    $c = ""

    if([int](($UPSEstRunTime.trimend(":00.00")).split(":")[0] + " days ").substring(0,2) -ne 0){
        $a =$UPSEstRunTime.trimend(":00.00").split(":")[0] + " days "
    }
    if([int](($UPSEstRunTime.trimend(":00.00")).split(":")[1] + " hours ").substring(0,2) -ne 0){
        $b = $UPSEstRunTime.trimend(":00.00").split(":")[1] + " hours "
    }
    if([int](($UPSEstRunTime.trimend(":00.00")).split(":")[2] + " minutes").substring(0,2) -ne 0){
        $c = $UPSEstRunTime.trimend(":00.00").split(":")[2] + " minutes"
    }

    $UPSEstRunTime = """"+$a + $b + $c+""""

    $UPSCharge = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $UPS "1.3.6.1.4.1.318.1.1.1.2.2.1")
    $UPSLoad = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $UPS "1.3.6.1.4.1.318.1.1.1.4.2.3")
    
    New-Object psobject -prop @{
        Name = $UPSUnintName
        RunTime = $UPSEstRunTime
        Charge = $UPSCharge
        Load = $UPSLoad
    }
    $splunkOutput = "$date $UPSUnitName : UnitID=$UPSUnitName RunTime=$UPSEstRunTime Charge=$UPSCharge Load=$UPSLoad"
    $splunkOutput | out-file -FilePath (join-path $path $filename) -append -Encoding utf8  
}
# SIG # Begin signature block
# MIIGUwYJKoZIhvcNAQcCoIIGRDCCBkACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUuS5usS3tFbQKStPfPStoiPm1
# KPegggRNMIIESTCCAzGgAwIBAgIKbALergAEAAAmzzANBgkqhkiG9w0BAQUFADBC
# MRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxEzARBgoJkiaJk/IsZAEZFgNocHMxFDAS
# BgNVBAMTC0hhbm5hbnByaW50MB4XDTE1MDQyOTA2NTA1MloXDTE2MDQyODA2NTA1
# MlowgY8xFTATBgoJkiaJk/IsZAEZFgVsb2NhbDETMBEGCgmSJomT8ixkARkWA2hw
# czESMBAGA1UECxMJSFBTIFVzZXJzMRowGAYDVQQLExFJVCBBZG1pbmlzdHJhdG9y
# czEZMBcGA1UECxMQT2ZmaWNlIDM2NSBJUE1HMTEWMBQGA1UEAxMNQ2hyaXMgQ29v
# bWJlczCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAvyg2r95Kmn4XCzs4eQzF
# KVgrRWEAAA1luJGRAob3Nz1j83RE6ENF2X9tTTe/TafN+g0NAB1SzmHpQhcVPgJF
# SJAMtrHHTgowSSlpUBa3Fx/CaQk0wEE6o0vdjSJMNWnMqmCFdBgJMM6Xv0Wc2KSm
# 7X9IchvHrab+S8nbym8hQuECAwEAAaOCAXUwggFxMCUGCSsGAQQBgjcUAgQYHhYA
# QwBvAGQAZQBTAGkAZwBuAGkAbgBnMBMGA1UdJQQMMAoGCCsGAQUFBwMDMAsGA1Ud
# DwQEAwIHgDAdBgNVHQ4EFgQUjAotvA29YQN+/Cq2Q37Pmtmr7uIwHwYDVR0jBBgw
# FoAU6DRp8P0y6MvKQcIsyxn7RDTSMz8wTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDov
# L2NybC5oYW5uYW5wcmludC5jb20uYXUvQ2VydEVucm9sbC9IYW5uYW5wcmludCg0
# KS5jcmwwaQYIKwYBBQUHAQEEXTBbMFkGCCsGAQUFBzAChk1odHRwOi8vY3JsLmhh
# bm5hbnByaW50LmNvbS5hdS9DZXJ0RW5yb2xsL2hwcy1kYzEuaHBzLmxvY2FsX0hh
# bm5hbnByaW50KDQpLmNydDAtBgNVHREEJjAkoCIGCisGAQQBgjcUAgOgFAwSY2Nv
# b21iZXNAaHBzLmxvY2FsMA0GCSqGSIb3DQEBBQUAA4IBAQATtP5CTP/bCP9ol3tF
# LDZX1RVrtRLIJ0zKaXKyEh2wv4OX3h2gpZb6oMnwyxxa8sr3Ssf3JBu/zHsSD1Vs
# UjE+5ubo+yTqcZ0hO6KeL/T+NOWCUMSvC6Um0HYYyRAdUNlq2nswburFEQJtC3Au
# RwA1mgAP0thH3hzPXoCfYc+dde5Uc3GYt6Ipq8qItqrW0aOvRO3ZKpwQUcTZA0oa
# dIJbrTxM+QrBUJFXSotouJgR3bKd2Qo2lhmj5T4WhEp+/fbprc+x+kB7/hvtpdcu
# ODi1oLb/De7qQR6DAgytTR1W6l2DPiD+ArIhVtcumEIl7B63UM3dtHQOl0HP6h0z
# 0QXqMYIBcDCCAWwCAQEwUDBCMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxEzARBgoJ
# kiaJk/IsZAEZFgNocHMxFDASBgNVBAMTC0hhbm5hbnByaW50AgpsAt6uAAQAACbP
# MAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3
# DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEV
# MCMGCSqGSIb3DQEJBDEWBBSCc8SzpA5ivwhHSphE75VfTAvsXTANBgkqhkiG9w0B
# AQEFAASBgH23WsRd90SgqliiiZismtGnoGDCHgCOpQcXyMhST71lWdDgoSypzIjt
# 3TRzNS1NmF10CqEVVQxLPYxh5YNV71HxY+qtdZ9nvOjQwNNrOV8pGPwXKCHNLHAV
# gW9gHjxjKe0PK8tM0IRkImIUwi/Wdgw8S2Va7+b8HWCs/V+j2E6J
# SIG # End signature block
