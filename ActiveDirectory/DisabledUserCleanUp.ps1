#test 1234

function Save-ADGroupMembership {
    param(
        $User
    )
    $Date = Get-Date -Format g
    $ADGroups = (Get-ADUser -Identity $User -Properties memberof).memberof

    $output = foreach($group in $ADGroups){

       $props =  [ordered]@{
            Date = $date
            User = $user
            Group = $group
        }
        
        New-Object psobject -Property $props
       
    }
    Write-Output $output
    $output | Export-CSV -Path "\\hps.local\public\Powershell\Files\Active Directory\DisabledUserGroupMembership.csv" -Append -Force -NoTypeInformation
}

$OUs = @(
    'OU=Disabled Users,OU=Users,OU=HPV Users,DC=hps,DC=local'
    'OU=HPS Disabled User accounts,DC=hps,DC=local'
    'OU=Disabled Users,OU=HPS Users,DC=hps,DC=local'
)

$users = $OUs | ForEach-Object {Get-ADUser -Filter * -SearchBase $_}


$group = Get-ADGroup -Identity "Disabled User Accounts" -Properties primaryGroupToken
$primaryGroupToken = $group.primaryGroupToken

foreach ($user in $users)
{
    $user | Set-ADUser -Description "Disabled"
    $user | Set-ADUser -DisplayName ("Disabled - "+$user.name)
    $user | Set-ADObject -replace @{msExchHideFromAddressLists=$true}
    
    $group | Add-ADGroupMember -Members $user -ErrorAction SilentlyContinue
            
    $user | Set-ADUser -Replace @{primaryGroupID=$primaryGroupToken}
    Save-ADGroupMembership -User $user
    (Get-ADUser $user -Properties memberof).memberof | Get-ADGroup | Remove-ADGroupMember -Members $user -Confirm:$false
}