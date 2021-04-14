# Import AD module
Import-Module ActiveDirectory
 
# Get your ad domain
$DomainName = (Get-ADDomain).DNSRoot
 
# Setup email parameters
$subject = "Domain Controllers in $DomainName"
$priority = "Normal"
$smtpServer = "email.xyz.com"
$emailFrom = "no-reply@xyz.com"
$emailTo = "user@xyz.com"
$port = 25
 
# Get all DC's
$AllDCs = Get-ADDomainController -Filter * -Server $DomainName | Select-Object Hostname,Ipv4address,Site,OperatingSystem
  
# Create empty DataTable object
$DCTable = New-Object System.Data.DataTable
      
# Add columns
$DCTable.Columns.Add() | Out-Null
$DCTable.Columns[0].Caption = "Hostname"
$DCTable.Columns[0].ColumnName = "Hostname"
  
$DCTable.Columns.Add() | Out-Null
$DCTable.Columns[1].Caption = "IPv4Address"
$DCTable.Columns[1].ColumnName = "IPv4Address"                     
  
$DCTable.Columns.Add() | Out-Null
$DCTable.Columns[2].Caption = "Site"
$DCTable.Columns[2].ColumnName = "Site"
  
$DCTable.Columns.Add() | Out-Null
$DCTable.Columns[3].Caption = "OperatingSystem"
$DCTable.Columns[3].ColumnName = "OperatingSystem"
 
$DCTable.Columns.Add() | Out-Null
$DCTable.Columns[4].Caption = "PingStatus"
$DCTable.Columns[4].ColumnName = "PingStatus"
 
# Loop each DC                        
ForEach($DC in $AllDCs)
{  
    $ping = ping $DC.Hostname -n 1 | Where-Object {$_ -match "Reply" -or $_ -match "Request timed out" -or $_ -match "Destination host unreachable"}
 
    switch ($ping)
    {
        {$_ -like "Reply*" }                          { $PingStatus = "Success" }
        {$_ -like "Request timed out*"}               { $PingStatus = "Timeout" }
        {$_ -like "Destination host unreachable*"}    { $PingStatus = "Unreachable" }
        default                                       { $PingStatus = "Unknown" }
    }
          
    $DCTable.Rows.Add(  $DC.Hostname,
                        $DC.Ipv4address,
                        $DC.Site,
                        $DC.OperatingSystem,
                        $PingStatus
                              
                        )| Out-Null                          
}
 
# Display results in console 
$DCTable | Sort-Object Site | Format-Table
 
#Creating head style
$Head = @"
<style>
  body {
    font-family: "Arial";
    font-size: 8pt;
    }
  th, td, tr { 
    border: 1px solid #e57300;
    border-collapse: collapse;
    padding: 5px;
    text-align: center;
    }
  th {
    font-size: 1.2em;
    text-align: left;
    background-color: #003366;
    color: #ffffff;
    }
  td {
    color: #000000;
     
    }
  .even { background-color: #ffffff; }
  .odd { background-color: #bfbfbf; }
  h6 { font-size: 12pt; 
       font-color: black;
       font-weight: bold;
       }
 
 text { font-size: 10pt;
        font-color: black;
        }
 }
</style>
"@
 
 
# Email body
[string]$body = [PSCustomObject]$DCTable | Select-Object Hostname,Ipv4address,Site,OperatingSystem,PingStatus | Sort-Object -Property Site | ConvertTo-HTML -Head $head -Body "<h6>Domain Controllers</h6></font>"
 
# Send the report email
Send-MailMessage -To $emailTo -Subject $subject -BodyAsHtml $body  -SmtpServer $smtpServer -Port $port -From $emailFrom -Priority $priority