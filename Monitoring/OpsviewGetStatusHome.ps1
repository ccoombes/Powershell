$resource = 'http://opsview.internal.georgieandchris.com/rest/login'

$postParams = @{username='admin';password='initial'}

$token = Invoke-RestMethod -Method POST -Uri $resource -Body $postParams

$resource = 'http://opsview.internal.georgieandchris.com/rest/status/hostgroup?parentid=1'

$postParams = @{"X-Opsview-Username"="admin";"X-Opsview-Token"=$token.token}

$result = Invoke-RestMethod -Method GET -Uri $resource -Headers $postParams -ContentType "application/json"

Write-Host "Host"
$result.summary.host | select up, down | ft
Write-Host "Service Summary"
$result.summary.service | select ok,critical,warning | ft
Write-Host "Service Breakdown"
$result.list | select name,@{name='OK';expression={$_.services.ok.handled}},@{name='Critcal';expression={$_.services.critical.unhandled}}, @{name='Warning';expression={$_.services.warning.unhandled}}, @{name='Unknown';expression={$_.services.unknown.unhandled}}  | ft