$cpu = Get-Random -Minimum 1 -Maximum 100
$memory = Get-Random -Minimum 1 -Maximum 100
$storage = Get-Random -Minimum 1 -Maximum 100

$uri1 = 'http://sensu:3030/widgets/cpu'
$body1 = @{
    auth_token = "YOUR_AUTH_TOKEN";
    value=$cpu;
}
$uri2 = 'http://sensu:3030/widgets/memory'
$body2 = @{
    auth_token = "YOUR_AUTH_TOKEN";
    value=$memory
}
$uri3 = 'http://sensu:3030/widgets/storage'
$body3 = @{
    auth_token = "YOUR_AUTH_TOKEN";
    value=$storage
}
$uri4 = 'http://sensu:3030/widgets/count'
$items = @()
$items += @{label = "Total"; value = "55"}
$items += @{label = "Powered On"; value = "50"}
$items += @{label = "Powered Off"; value = "5"}
 
$props = [ordered]@{
auth_token = "YOUR_AUTH_TOKEN"
items = $items
}
 
Invoke-RestMethod -Method Post -Uri "$uri1" -Body (ConvertTo-Json $body1)
Invoke-RestMethod -Method Post -Uri "$uri2" -Body (ConvertTo-Json $body2)
Invoke-RestMethod -Method Post -Uri "$uri3" -Body (ConvertTo-Json $body3)
Invoke-RestMethod -Method Post -Uri "$uri4" -Body (ConvertTo-Json $props)