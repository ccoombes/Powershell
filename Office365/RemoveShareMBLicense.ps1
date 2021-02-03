$shared = Get-Mailbox -RecipientTypeDetails "Shared" | select userprincipalname

foreach ($mb in $shared)
{
    $licenses = Get-MsolUser -UserPrincipalName $mb.UserPrincipalName | select -ExpandProperty Licenses

    foreach ($license in $licenses)
    {
        Get-MsolUser -UserPrincipalName $mb.UserPrincipalName | where islicensed -eq $true | Set-MsolUserLicense -RemoveLicense $license.AccountSkuId -Verbose
    }
}