Get-MsolAccountSku | where {$_.skupartnumber -eq "ENTERPRISEPACK" -or $_.skupartnumber -eq "STANDARDPACK" -or $_.skupartnumber -eq "EXCHANGESTANDARD"} | select skupartnumber,activeunits,consumedunit
