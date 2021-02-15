$resource = 'http://hpnopsview.hps.local/rest/login'

$postParams = @{username='admin';password='_100ops_85%'}

$token = Invoke-RestMethod -Method POST -Uri $resource -Body $postParams

$hosts = "ipd-wf-esxi01.ipmgprint.com.au","ipd-wf-esxi02.ipmgprint.com.au","ipd-wf-esxi03.ipmgprint.com.au","ipd-wf-esxi04.ipmgprint.com.au"

$output = foreach ($vmhost in $hosts)
{
    
    $resource = 'http://hpnopsview.hps.local/rest/status/service?host='+$vmhost

    $postParams = @{"X-Opsview-Username"="admin";"X-Opsview-Token"=$token.token}

    $result = Invoke-RestMethod -Method GET -Uri $resource -Headers $postParams -ContentType "application/json"
    New-Object psobject -Property   @{
        Name=$vmhost
        CPU=($result.list.services | where name -eq 'Host CPU Usage').output.split("=")[1].trimend(" %")
        Memory=($result.list.services | where name -eq 'Host Memory Usage').output.split("=")[1].trimend(" %")
    }
}

$output


