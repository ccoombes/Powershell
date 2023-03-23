<#
.DESCRIPTION
  Query Active Directory using SID without AD Tools
.NOTES
  Version:        1.0
  Author:         Chris Coombes
  Email:          ccoombes@outlook.com
  Creation Date:  16-02-2023
  Purpose/Change: Initial script development
#>

$sids = Get-Content C:\Temp\SIDs.txt

$output = foreach ($a in $sids)
{
    $b = ""
    $b = ($a.Split(",")[0]).trim("CN=")

    $sid = ""    
    $SID = New-Object System.Security.Principal.SecurityIdentifier($b)
    # Use Translate to find user from sid

    $objuser = ""
    $objUser = $SID.Translate([System.Security.Principal.NTAccount])
    # Print the converted SID to username value
    
    $tnumber = ""
    $tnumber = ($objUser.Value).Split("\")[1]

    $getad = ""
    $getad = (([adsisearcher]"(&(objectCategory=User)(samaccountname=$tnumber))").findall()).properties
    
    $props = [ordered]@{
            Name = [string]$getad.displayname
            Tnumber = [string]$getad.name
            Company = [string]$getad.extensionattribute9 
            mail = [string]$getad.mail
            title = [string]$getad.title
    }

    New-object psobject -Property $props
}

$output | Format-Table