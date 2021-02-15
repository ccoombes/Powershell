$Path = "\\hpnsplunk\SplunkLogs"
$filename = "SwitchMonitorLogs.txt"

$Switches = '10.105.1.1','10.105.1.2','10.100.150.104','10.100.150.105','10.100.150.106','10.100.150.3','10.100.150.5','10.100.150.7','10.100.150.9','10.100.150.11','10.100.150.13','10.100.150.15'

$date=(get-date -UFormat "%b %d %Y %T")

$SwitchMonitorOutput = foreach ($Switch in $Switches){

    $SYSName = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "sysname")
    $SYSLocation = """"+(c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "syslocation")+""""
    $SYSUptime = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "sysuptime")
    
    $a =$SYSUptime.trimend(":00.00").split(":")[0] + " days "
    $b = $SYSUptime.trimend(":00.00").split(":")[1] + " hours "
    $c = $SYSUptime.trimend(":00.00").split(":")[2] + " minutes"

    $SYSUptime = """"+$a + $b + $c+""""

    $StackMembers = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.107.1.1.2").count
      
    if ($StackMembers -eq 1) {
                
        $Temp = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.5.1.1.2.1")
        $PrimaryPowerSupply = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.2.1.3")[0]
        if($PrimaryPowerSupply -eq 5){$PrimaryPowerSupply="""Not Present"""}
        if($PrimaryPowerSupply -eq 6){$PrimaryPowerSupply="""Not Functioning"""}
        if($PrimaryPowerSupply -eq 1){$PrimaryPowerSupply="""Normal"""}
        $RedundantPowerSupply = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.2.1.3")[1]
        if($RedundantPowerSupply -eq 5){$RedundantPowerSupply="""Not Present"""}
        if($RedundantPowerSupply -eq 6){$RedundantPowerSupply="""Not Functioning"""}
        if($RedundantPowerSupply -eq 1){$RedundantPowerSupply="""Normal"""}
        $Fans = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.1.1.3")
        if(([int]$Fans[0]+[int]$Fans[1]) -eq 2 -OR ([int]$Fans[0]+[int]$Fans[1]) -eq 8){$Fans = "OK"}
        else{$Fans = "Faulty"}

        $splunkOutput = "$date $SYSName : SYSName=$SYSName SYSIp=$Switch SYSLocation=$SYSLocation SYSUptime=$SYSUptime StackMember=1 OperatingTemp=$Temp PrimaryPowerSupplyStatus=$PrimaryPowerSupply RedundentPowerSupplyStatus=$RedundantPowerSupply FanStatus=$Fans"
        $splunkOutput | out-file -FilePath (join-path $path $filename) -append -Encoding utf8
    }
    if ($StackMembers -eq 2) {
        
        #First Stack Member
                
        $Temp = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.5.1.1.2.1")
        $PrimaryPowerSupply = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.2.1.3")[0]
        if($PrimaryPowerSupply -eq 5){$PrimaryPowerSupply="""Not Present"""}
        if($PrimaryPowerSupply -eq 6){$PrimaryPowerSupply="""Not Functioning"""}
        if($PrimaryPowerSupply -eq 1){$PrimaryPowerSupply="""Normal"""}
        $RedundantPowerSupply = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.2.1.3")[1]
        if($RedundantPowerSupply -eq 5){$RedundantPowerSupply="""Not Present"""}
        if($RedundantPowerSupply -eq 6){$RedundantPowerSupply="""Not Functioning"""}
        if($RedundantPowerSupply -eq 1){$RedundantPowerSupply="""Normal"""}
        $Fans = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.1.1.3")
        if(([int]$Fans[0]+[int]$Fans[1]) -eq 2 -OR ([int]$Fans[0]+[int]$Fans[1]) -eq 8){$Fans = "OK"}
        else{$Fans = "Faulty"}

        $splunkOutput = "$date $SYSName : SYSName=$SYSName-1 SYSIp=$Switch SYSLocation=$SYSLocation SYSUptime=$SYSUptime StackMember=1 OperatingTemp=$Temp PrimaryPowerSupplyStatus=$PrimaryPowerSupply RedundentPowerSupplyStatus=$RedundantPowerSupply FanStatus=$Fans"
        $splunkOutput | out-file -FilePath (join-path $path $filename) -append -Encoding utf8

        #Second Stack Member

        $Temp = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.5.1.1.2.2")
        $PrimaryPowerSupply = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.2.1.3")[2]
        if($PrimaryPowerSupply -eq 5){$PrimaryPowerSupply="""Not Present"""}
        if($PrimaryPowerSupply -eq 6){$PrimaryPowerSupply="""Not Functioning"""}
        if($PrimaryPowerSupply -eq 1){$PrimaryPowerSupply="""Normal"""}
        $RedundantPowerSupply = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.2.1.3")[3]
        if($RedundantPowerSupply -eq 5){$RedundantPowerSupply="""Not Present"""}
        if($RedundantPowerSupply -eq 6){$RedundantPowerSupply="""Not Functioning"""}
        if($RedundantPowerSupply -eq 1){$RedundantPowerSupply="""Normal"""}
        $Fans = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.1.1.3")
        if(([int]$Fans[2]+[int]$Fans[3]) -eq 2 -OR ([int]$Fans[2]+[int]$Fans[3]) -eq 8){$Fans = "OK"}
        else{$Fans = "Faulty"}

        $splunkOutput = "$date $SYSName : SYSName=$SYSName-2 SYSIp=$Switch SYSLocation=$SYSLocation SYSUptime=$SYSUptime StackMember=2 OperatingTemp=$Temp PrimaryPowerSupplyStatus=$PrimaryPowerSupply RedundentPowerSupplyStatus=$RedundantPowerSupply FanStatus=$Fans"
        $splunkOutput | out-file -FilePath (join-path $path $filename) -append -Encoding utf8
    }
    if ($StackMembers -eq 3) {
        
        #First Stack Member
                
        $Temp = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.5.1.1.2.1")
        $PrimaryPowerSupply = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.2.1.3")[0]
        if($PrimaryPowerSupply -eq 5){$PrimaryPowerSupply="""Not Present"""}
        if($PrimaryPowerSupply -eq 6){$PrimaryPowerSupply="""Not Functioning"""}
        if($PrimaryPowerSupply -eq 1){$PrimaryPowerSupply="""Normal"""}
        $RedundantPowerSupply = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.2.1.3")[1]
        if($RedundantPowerSupply -eq 5){$RedundantPowerSupply="""Not Present"""}
        if($RedundantPowerSupply -eq 6){$RedundantPowerSupply="""Not Functioning"""}
        if($RedundantPowerSupply -eq 1){$RedundantPowerSupply="""Normal"""}
        $Fans = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.1.1.3")
        if(([int]$Fans[0]+[int]$Fans[1]) -eq 2 -OR ([int]$Fans[0]+[int]$Fans[1]) -eq 8){$Fans = "OK"}
        else{$Fans = "Faulty"}

        $splunkOutput = "$date $SYSName : SYSName=$SYSName-1 SYSIp=$Switch SYSLocation=$SYSLocation SYSUptime=$SYSUptime StackMember=1 OperatingTemp=$Temp PrimaryPowerSupplyStatus=$PrimaryPowerSupply RedundentPowerSupplyStatus=$RedundantPowerSupply FanStatus=$Fans"
        $splunkOutput | out-file -FilePath (join-path $path $filename) -append -Encoding utf8

        #Second Stack Member

        $Temp = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.5.1.1.2.2")
        $PrimaryPowerSupply = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.2.1.3")[2]
        if($PrimaryPowerSupply -eq 5){$PrimaryPowerSupply="""Not Present"""}
        if($PrimaryPowerSupply -eq 6){$PrimaryPowerSupply="""Not Functioning"""}
        if($PrimaryPowerSupply -eq 1){$PrimaryPowerSupply="""Normal"""}
        $RedundantPowerSupply = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.2.1.3")[3]
        if($RedundantPowerSupply -eq 5){$RedundantPowerSupply="""Not Present"""}
        if($RedundantPowerSupply -eq 6){$RedundantPowerSupply="""Not Functioning"""}
        if($RedundantPowerSupply -eq 1){$RedundantPowerSupply="""Normal"""}
        $Fans = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.1.1.3")
        if(([int]$Fans[2]+[int]$Fans[3]) -eq 2 -OR ([int]$Fans[2]+[int]$Fans[3]) -eq 8){$Fans = "OK"}
        else{$Fans = "Faulty"}

        $splunkOutput = "$date $SYSName : SYSName=$SYSName-2 SYSIp=$Switch SYSLocation=$SYSLocation SYSUptime=$SYSUptime StackMember=2 OperatingTemp=$Temp PrimaryPowerSupplyStatus=$PrimaryPowerSupply RedundentPowerSupplyStatus=$RedundantPowerSupply FanStatus=$Fans"
        $splunkOutput | out-file -FilePath (join-path $path $filename) -append -Encoding utf8

        #ThirdStack Member

        $Temp = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.5.1.1.2.3")
        $PrimaryPowerSupply = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.2.1.3")[4]
        if($PrimaryPowerSupply -eq 5){$PrimaryPowerSupply="""Not Present"""}
        if($PrimaryPowerSupply -eq 6){$PrimaryPowerSupply="""Not Functioning"""}
        if($PrimaryPowerSupply -eq 1){$PrimaryPowerSupply="""Normal"""}
        $RedundantPowerSupply = [int](c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.2.1.3")[5]
        if($RedundantPowerSupply -eq 5){$RedundantPowerSupply="""Not Present"""}
        if($RedundantPowerSupply -eq 6){$RedundantPowerSupply="""Not Functioning"""}
        if($RedundantPowerSupply -eq 1){$RedundantPowerSupply="""Normal"""}
        $Fans = (c:\usr\bin\snmpwalk.exe -v 1 -c hp-public -O vq $Switch "1.3.6.1.4.1.89.83.1.1.1.3")
        if(([int]$Fans[4]+[int]$Fans[5]) -eq 2 -OR ([int]$Fans[4]+[int]$Fans[5]) -eq 8){$Fans = "OK"}
        else{$Fans = "Faulty"}

        $splunkOutput = "$date $SYSName : SYSName=$SYSName-3 SYSIp=$Switch SYSLocation=$SYSLocation SYSUptime=$SYSUptime StackMember=3 OperatingTemp=$Temp PrimaryPowerSupplyStatus=$PrimaryPowerSupply RedundentPowerSupplyStatus=$RedundantPowerSupply FanStatus=$Fans"
        $splunkOutput | out-file -FilePath (join-path $path $filename) -append -Encoding utf8
    }
}
# SIG # Begin signature block
# MIIGUwYJKoZIhvcNAQcCoIIGRDCCBkACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAkN5xOp4WIrQi9/3kW+FHQ2P
# r2igggRNMIIESTCCAzGgAwIBAgIKbALergAEAAAmzzANBgkqhkiG9w0BAQUFADBC
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
# MCMGCSqGSIb3DQEJBDEWBBTyIE6ELfibk64dvsyEKCTgSixOsTANBgkqhkiG9w0B
# AQEFAASBgKGNunqmQpJdQCxTV/L1bk7iiDAdY5v9WKD6fJABnUf0tqnjSBFv/Iqz
# sEVTNtY9M8Z1mdrBz17tlKyQvlacGQS3PhuwLGF9rHGhSv9+oDsZZRlJhKMsDKxy
# PBXQfJCqZ/wuZrzkuUp+7tudBJbvdZuzXQH44O4sqa0n47y0VDL3
# SIG # End signature block
