<#
.DESCRIPTION
  <Brief description of script>
.NOTES
  Version:        1.0
  Author:         Chris Coombes
  Email:          ccoombes@outlook.com
  Creation Date:  01-01-2021
  Purpose/Change: Initial script development
#>
$Result=@() 
$users = Get-MsolUser -All
$users | Where-Object BlockCredential -eq $false | ForEach-Object {
$user = $_
$mfaStatus = $_.StrongAuthenticationRequirements.State 
$methodTypes = $_.StrongAuthenticationMethods 
 
if ($mfaStatus -ne $null -or $methodTypes -ne $null)
{
if($mfaStatus -eq $null)
{ 
$mfaStatus='Enabled (Conditional Access)'
}
$authMethods = $methodTypes.MethodType
$defaultAuthMethod = ($methodTypes | Where{$_.IsDefault -eq "True"}).MethodType 
$verifyEmail = $user.StrongAuthenticationUserDetails.Email 
$phoneNumber = $user.StrongAuthenticationUserDetails.PhoneNumber
$alternativePhoneNumber = $user.StrongAuthenticationUserDetails.AlternativePhoneNumber
}
Else
{
$mfaStatus = "Disabled"
$defaultAuthMethod = $null
$verifyEmail = $null
$phoneNumber = $null
$alternativePhoneNumber = $null
}
    
$Result += New-Object PSObject -property @{ 
UserName = $user.DisplayName
UserPrincipalName = $user.UserPrincipalName
DisplayName = $user.DisplayName
SignInName = $user.SignInName
Licensed = $user.IsLicensed
Exchange = $user.MSExchRecipientTypeDetails
Title = $user.Title
Office = $user.Office
County = $user.Country
MFAStatus = $mfaStatus
AuthenticationMethods = $authMethods
DefaultAuthMethod = $defaultAuthMethod
MFAEmail = $verifyEmail
PhoneNumber = $phoneNumber
AlternativePhoneNumber = $alternativePhoneNumber
}
}
$totalUsers = ($Result | where {$_.licensed -eq $true} | measure).count
$MFAdisabled = ($Result | where {$_.licensed -eq $true -and $_.mfastatus -eq "Disabled"}  | measure).count
$MFAenabled = ($Result | where {$_.licensed -eq $true -and $_.mfastatus -eq "Enabled"}  | measure).count
$MFAenfored = ($Result | where {$_.licensed -eq $true -and $_.mfastatus -eq "Enforced"}  | measure).count

$summary = new-object -TypeName PSObject
$summary | Add-Member -type noteproperty -Name 'Total Licensed Users' -Value $totalUsers
$summary | Add-Member -type noteproperty -Name 'MFA Disabled' -Value $MFAdisabled
$summary | Add-Member -type noteproperty -Name 'MFA Enabled' -Value $MFAenabled
$summary | Add-Member -type noteproperty -Name 'MFA Enforced' -Value $MFAenfored

$file = "C:\Temp\OVTO365MFAReport.csv"
$Result | where licensed -eq $true | Select UserName,userprincipalname,MFAStatus,MFAEmail,DefaultAuthMethod,PhoneNumber,AlternativePhoneNumber |  Export-Csv -Path $file -NoTypeInformation

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

$htmlsummary = $summary | ConvertTo-Html -As List -Head $header -PreContent "<h2>Ovato Office 365 MFA Summary Report</h2>" | Out-String

#email with attachment

$emailParams = @{
    From = "Ovato Jenkins Automation <jenkins@ovato.com.au>";
    To = "chris.coombes@ovato.com.au";
    Subject = "Office 365 MFA Report";
    Attachments = $file;
    body = $htmlsummary
    SmtpServer = "email.pmplimited.com.au";
}

Send-MailMessage @emailParams -BodyAsHtml

Write-Host "Sending email with attachment to "$Email

#delete attachment

Remove-Item -Path $file