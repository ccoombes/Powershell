<#
.DESCRIPTION
  <Brief description of script>
.NOTES
  Version:        1.0
  Author:         Chris Coombes
  Email:          ccoombes@outlook.com
  Creation Date:  04-02-2021
  Purpose/Change: Initial script development
#>
$users = Get-MsolUser -all | where {$_.islicensed -eq $true} 

$output = foreach ($user in $users)
{
    $EXCHANGE = ""
    $E1 = ""
    $E3 = ""
    
    $lastLogon = Get-MailboxStatistics -Identity $user.UserPrincipalName | select LastLogonTime

    foreach ($license in $user.Licenses)
    {
        if ($license.AccountSkuId -eq "pmplimited:EXCHANGESTANDARD"){$EXCHANGE = "YES"}
        if ($license.AccountSkuId -eq "pmplimited:STANDARDPACK"){$E1 = "YES"}
        if ($license.AccountSkuId -eq "pmplimited:ENTERPRISEPACK"){$E3 = "YES"}
    }

    $props = [ordered]@{
        Name = $user.DisplayName
        UPN = $user.UserPrincipalName
        LOGON = $lastLogon
        CITY = $user.City
        OFFICE = $user.Office
        DEPARTMENT = $user.Department
        P1 = $EXCHANGE
        E1 = $E1
        E3 = $E3
    }
    
    New-Object PSObject -Property $props
}

$output |  Export-Csv C:\Temp\Ovato2019-O365LicenseBreakdown2.csv -NoTypeInformation
