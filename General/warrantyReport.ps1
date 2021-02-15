$SQLServer = "hpssql2008" #use Server\Instance for named SQL instances! 
$SQLDBName = "SystemCenterEssentials"
$SqlQuery = "select * from AllDellComputers"

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True"

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection

$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd

$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet) 
$SqlConnection.Close()

$dellcomputers = $DataSet.Tables[0]

Import-Module C:\AutoMationScripts\Modules\getHPSDellWarrantyInfo.psm1
Import-Module C:\AutoMationScripts\Modules\getDateDiff.psm1

$today=Get-Date

$computers = $dellcomputers | where {$_.servicetag -ne ""} | foreach {
	$warranty = get-hpsDellWarrantyInfo -ServiceTagInput $_.ServiceTag
	$type = "Unknown"
	
	if ($_.model -like "*optiplex*"){$type="Desktop"}
	if ($_.model -like "*poweredge*"){$type="Server"}
	if ($_.model -like "*latitude*"){$type="Notebook"}
	if ($_.model -like "*vostro v*"){$type="Notebook"}
	if ($_.model -like "*precision*"){$type="Workstation"}
	
	if ($warranty -ne $null)
	{
		New-Object PSObject -prop @{
			Computer = $_.ComputerName
			Model = $_.Model
			AssetType = $Type
			ServiceTag = $_.ServiceTag
			ADSite = $_.ActiveDirectorySite
			ShipDate = $warranty.ShipDate
			StartDate = $warranty.StartDate
			EndDate = $warranty.EndDate
			DaysLeft = [int]$warranty.DaysLeft
			DaysOut = (Get-DateDiff $today ($warranty.EndDate)).days
			Status = "Updated"
		}
	}
	else
	{
			New-Object PSObject -prop @{
			Computer = $_.ComputerName
			Model = $_.Model
			AssetType = $Type
			ServiceTag = $_.ServiceTag
			ADSite = $_.ActiveDirectorySite
			Status = "Error"
		}
	}
}


$renewWarranty = $computers | where {$_.shipDate -ge ($today.addYears(-5)) -and $_.enddate -ge $today.AddMonths(-6) -and $_.daysLeft -le "30" -and $_.status -ne "Error"} | Sort-Object enddate | select Computer, ServiceTag, Model, AssetType, ADSite, ShipDate, StartDate, EndDate, DaysLeft
if ($renewWarranty -ne $null){
	$renewCount = $renewWarranty.Count
	$renewWarranty = $renewWarranty | ConvertTo-HTML -Fragment
} 
else{ 
	$renewCount = '0'
	$renewWarranty = "<b>No Computers</b>"
}

$outofWarranty = $computers | where {$_.enddate -le $today.AddMonths(-6) -or $_.shipdate -le $today.AddYears(-5) -and $_.daysleft -eq 0 -and $_.status -ne "Error"} | Sort-Object enddate | select Computer, ServiceTag, Model, AssetType, ADSite, ShipDate, StartDate, EndDate, DaysOut 
if ($outofWarranty -ne $null){
	$outCount = $outofWarranty.Count
	$outofWarranty = $outofWarranty | ConvertTo-HTML -Fragment 
} 
else{ 
	$outCount = '0'
	$outofWarranty = "<b>No Computers</b>"
}

$abouttoRunOutofWarranty = $computers | where {$_.enddate -ge ($today.AddDays(-30)) -and $_.enddate -le $today -and $_.shipdate -le $today.AddYears(-4.5) -and $_.status -ne "Error"} | Sort-Object enddate | select Computer, ServiceTag, Model, AssetType, ADSite, ShipDate, StartDate, EndDate, DaysLeft 
if ($abouttoRunOutofWarranty -ne $null){
	$expireCount = $abouttoRunOutofWarranty.Count
	$abouttoRunOutofWarranty = $abouttoRunOutofWarranty | ConvertTo-HTML -Fragment 
} 
else{ 
	$expireCount = '0' 
	$abouttoRunOutofWarranty = "<b>No Computers</b>"
}

$errors = $computers | where {$_.status -eq "error"} | select Computer, ServiceTag, Model, AssetType, ADSite
if ($errors -ne $null){
	$errorCount = $errors.Count
	$errors = $errors | ConvertTo-HTML -Fragment 
} 
else{ 
	$errorCount = '0' 
	$errors = "<b>No Computers</b>"
}

$a = "<style>"
$a = $a + "BODY{background-color:white; font-family:Tahoma; font-size: 11px}"
$a = $a + "TABLE{border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black;background-color:lightblue}"
$a = $a + "TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black;background-color:lightyellow}"
$a = $a + "H2{color: red;}"
$a = $a + "</style>"

$summary = "<table>"
$summary = $summary + "<tr>"
$summary = $summary + "<th>Warranty Report</th>"
$summary = $summary + "<th>Number of Computers</th>"
$summary = $summary + "</tr>"
$summary = $summary + "<tr>"
$summary = $summary + "<td>Warranty to be Renewed</td>"
$summary = $summary + "<td>" + $renewCount + "</td>"
$summary = $summary + "</tr>"
$summary = $summary + "<tr>"
$summary = $summary + "<td>Computers out of Warranty</td>"
$summary = $summary + "<td>"+ $outCount +"</td>"
$summary = $summary + "</tr>"
$summary = $summary + "<tr>"
$summary = $summary + "<td>Warranty About to Expire</td>"
$summary = $summary + "<td>" + $expireCount + "</td>"
$summary = $summary + "</tr>"
$summary = $summary + "<tr>"
$summary = $summary + "<td>Errors</td>"
$summary = $summary + "<td>" + $errorCount + "</td>"
$summary = $summary + "</tr>"
$summary = $summary + "</table>"

ConvertTo-Html -head $a -body "

<H1>Dell Warranty Report</H1>
<p> $today </p>
<H2>Summary</H2>
$summary
<H2>Renew Warranty</H2>
<p>Computers purchase in the last 3 years, which are eligible to have their warranty renewed</p> 
$renewWarranty 
<H2>Out of Warranty</H2>
<p>Computers still in production with expired warranties, which are not eligible to be renewed</p>
$outOfWarranty
<H2>Warranty About to Expire (30 Days)</H2>
<p>Computers currently in production with their warranites about to expire, which are not eligible to be renewed</p> 
$abouttoRunOutofWarranty 
<H2>Error Retriving Warranty Information</H2>
<p>These computers need there waranty information checked manually</p> 
$errors" |

Out-File c:\Temp\DellWarrantyReport.html

$smtpServer = "hps-exch1"

$file = "c:\Temp\DellWarrantyReport.html"
$att = new-object Net.Mail.Attachment($file)

$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = "powershell@hannanprint.com.au"
$msg.To.Add("ccoombes@hannanprint.com.au")
$msg.Subject = "Dell Warranty Report"
$msg.Body = "Attached is the Dell Warranty report"
$msg.Attachments.Add($att)

$smtp.Send($msg)
$att.Dispose()