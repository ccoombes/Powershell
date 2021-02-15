$username = 'kyounan'

Set-ADUser $username -Remove @{proxyAddresses = 'SMTP:'+$username+'@hannanprint.com.au'}
Set-ADUser $username -Remove @{proxyAddresses = 'smtp:'+$username+'@ipmg.com.au'}

Set-ADUser $username -Add @{proxyAddresses = 'smtp:'+$username+'@hannanprint.com.au'}
Set-ADUser $username -Add @{proxyAddresses = 'SMTP:'+$username+'@ipmg.com.au'}

Set-ADUser $username -EmailAddress $username+'@ipmg.com.au'

Get-ADUser $username -Properties mail
Get-ADUser $username -Properties proxyAddresses | select * -ExpandProperty proxyaddresses