<#
.DESCRIPTION
  List all user mailboxes that have been converted to shared with an active Office 365 license.
.NOTES
  Version:        1.0
  Author:         Chris Coombes
  Email:          ccoombes@outlook.com
  Creation Date:  28-1-2021
  Purpose/Change: Initial script development
#>

Get-Mailbox -RecipientTypeDetails shared | Get-MsolUser | Where-Object islicensed -eq $true
