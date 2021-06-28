function Start-OVTO365LicenseReport {
    [CmdletBinding()]

    param (
        [string]$Email
    )

    $users = Get-MsolUser -all | Where-Object {$_.islicensed -eq $true} 

    $output = foreach ($user in $users)
    {
        #set all variable to null
        
        $EXCHANGE = ""
        $E1 = ""
        $E3 = ""
        $VISIO = ""
        $PRO = ""
        $BI = ""
        
        #$lastLogon = Get-MailboxStatistics -Identity $user.UserPrincipalName | select LastLogonTime

        foreach ($license in $user.Licenses)
        {
            if ($license.AccountSkuId -eq "pmplimited:EXCHANGESTANDARD"){$EXCHANGE = "YES"}
            if ($license.AccountSkuId -eq "pmplimited:STANDARDPACK"){$E1 = "YES"}
            if ($license.AccountSkuId -eq "pmplimited:ENTERPRISEPACK"){$E3 = "YES"}
            if ($license.AccountSkuId -eq "pmplimited:VISIOCLIENT"){$VISIO = "YES"}
            if ($license.AccountSkuId -eq "pmplimited:OFFICESUBSCRIPTION"){$PRO = "YES"}
            if ($license.AccountSkuId -eq "pmplimited:POWER_BI_PRO"){$BI = "YES"}
        }

        $props = [ordered]@{
            Name = $user.DisplayName
            UPN = $user.UserPrincipalName
            #LOGON = $lastLogon
            CITY = $user.City
            OFFICE = $user.Office
            DEPARTMENT = $user.Department
            P1 = $EXCHANGE
            E1 = $E1
            E3 = $E3
            VISIO = $VISIO
            PRO = $PRO
            BI = $BI
        }
        
        New-Object PSObject -Property $props
    }
    #Summary
    $summary = Get-MsolAccountSku | select skupartnumber,activeunits,consumedunits
    $htmlsummary = $summary | ConvertTo-Html -As Table -Head $header -PreContent $precontent -PostContent $postcontent | Out-String

    #output csv file$po

    $file = "C:\Temp\OVTO365LicenseReport.csv"
    $output |  Export-Csv -Path $file -NoTypeInformation

    #email with attachment

    $emailParams = @{
        From = "Ovato Jenkins Automation <jenkins@ovato.com.au>";
        To = "chris.coombes@ovato.com.au";
        Subject = "Office 365 License Report";
        Body = $htmlsummary
        Attachments = $file;
        SmtpServer = "email.pmplimited.com.au"
    }

    Send-MailMessage @emailParams -BodyAsHtml

    Write-Host "Sending email with attachment to "$Email

    #delete attachment

    Remove-Item -Path $file
}

$header = @"
<style>
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: orange;
        font-size: 16px;

    }
    
    table {
        font-size: 12px;
        border: 0px; 
        font-family: Arial, Helvetica, sans-serif;
    } 
    
    td {
        padding: 4px;
        margin: 0px;
        border: 0;
    }
    
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
    }

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }

    #CreationDate {
        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;
    }
</style>
"@

$precontent = @"
<h2>Ovato Office 365 Consumed License Report</h2>
"@

$postcontent = @"
<h3>Microsoft SKU Summary</h3>
<a href="https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference">Product names and service plan identifiers</a>
"@