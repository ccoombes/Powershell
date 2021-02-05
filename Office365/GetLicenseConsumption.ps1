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
Get-MsolAccountSku | where {$_.skupartnumber -eq "ENTERPRISEPACK" -or $_.skupartnumber -eq "STANDARDPACK" -or $_.skupartnumber -eq "EXCHANGESTANDARD"} | select skupartnumber,activeunits,consumedunit
