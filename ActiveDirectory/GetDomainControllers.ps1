$AllDCs = Get-ADDomainController -Filter * -Server 'pmplimited.com.au' | Select-Object Hostname,Ipv4address,isglobalcatalog,site,forest,operatingsystem