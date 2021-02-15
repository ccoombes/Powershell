$uri1 = 'https://dashku.com/api/dashboards?apiKey=d024d30a-7999-4e55-bf7b-b93ec49198d1'
$body1 = @{
  bigNumber='50';
  _id= "57798f9b53146d7909011a46";
}

Invoke-RestMethod -Method put -Uri "$uri1" -Body (ConvertTo-Json $body1)