# PowerShell Test-Connection to measure a server's response time

$Resources = Import-Csv "\\hps\public\powershell\Scripts\Monitoring\Resources.csv"

$response = foreach ($Resource in $Resources) {
    $Status = "Up"

    $PingServer = Test-Connection -count 3 $Resource.IP -ErrorAction SilentlyContinue
    
    $Avg = ($PingServer | Measure-Object ResponseTime -average)

    [int]$AvgResponse = [System.Math]::Round($Avg.average)

    if($AvgResponse -eq 0){$Status = "Down"}

    $props = [ordered]@{
        
        SYSName = $Resource.Name
        SYSIp = $Resource.IP
        SYSType = $Resource.ResourceType
        Status = $Status
        AverageResponse = $AvgResponse

    }

    New-Object psobject -Property $props

}

$response | Export-Splunk -filename PingLogs.txt
# SIG # Begin signature block
# MIIGUwYJKoZIhvcNAQcCoIIGRDCCBkACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU8KQGfI7CqN0E6mTDlENSSHXQ
# kZGgggRNMIIESTCCAzGgAwIBAgIKbALergAEAAAmzzANBgkqhkiG9w0BAQUFADBC
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
# MCMGCSqGSIb3DQEJBDEWBBRM7uTNuerc34gUnJcGpz4DkDKThDANBgkqhkiG9w0B
# AQEFAASBgASgI9dnWE8C1gVPwoa1LfyvFTt6tXvDssQO5LWJMCkDDfFISLIRTGJv
# 3/jQpZDI0WNHhlsNtoPAYZxmgW6YtdKECD/gmtUU02Hc3WQVzMbqJg/Tj26+C9i2
# Ay3JNGSigntddmfb/gO5ysHQW9rB/BzATvi2CihE34dr5g1QL2qR
# SIG # End signature block
