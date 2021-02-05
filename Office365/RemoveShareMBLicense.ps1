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
$shared = Get-Mailbox -RecipientTypeDetails "Shared" | select userprincipalname

foreach ($mb in $shared)
{
    $licenses = Get-MsolUser -UserPrincipalName $mb.UserPrincipalName | select -ExpandProperty Licenses

    foreach ($license in $licenses)
    {
        Get-MsolUser -UserPrincipalName $mb.UserPrincipalName | where islicensed -eq $true | Set-MsolUserLicense -RemoveLicense $license.AccountSkuId -Verbose
    }
}