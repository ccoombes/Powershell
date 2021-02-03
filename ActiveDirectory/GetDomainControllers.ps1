<#
.DESCRIPTION
  List all Active Directory Domain Controllers for a particular domain
.NOTES
  Version:        1.0
  Author:         Chris Coombes
  Email:          ccoombes@outlook.com
  Creation Date:  03-03-2021
  Purpose/Change: Initial script development
#>

$domain = "abc.xyx"
$AllDCs = Get-ADDomainController -Filter * -Server $domain 
$AllDCs | Select-Object Hostname,Ipv4address,isglobalcatalog,site,forest,operatingsystem