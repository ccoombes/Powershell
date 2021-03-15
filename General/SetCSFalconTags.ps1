<#
.DESCRIPTION
  Add Tags to list of Crowdstike Hosts
  Used to activate protect mode after removing current AV
  Requires the PSFalcon module
.NOTES
  Version:        1.0
  Author:         Chris Coombes
  Email:          ccoombes@outlook.com
  Creation Date:  05-03-2021
  Purpose/Change: Initial script development
#>
function Set-CSFalconTags
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$True)]
        [String[]]
        $HostList,

        [parameter(Mandatory=$True)]
        [String]
        $Tags
    )
    
    Import-Module -Name PSFalcon
    Request-FalconToken -ClientId $env:ClientID -ClientSecret $env:ClientSecret -Cloud us-2

    $HostList = $HostList.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) | Select-Object -Unique #Split on new line in jenkins
    $IDs = ForEach ($FalconHost in $HostList) { 
        $filter = "hostname: '"+$FalconHost+"'"
        Get-FalconHost -Filter $filter -Verbose
    }
    
    Add-FalconHostTag -Tags $tags -Ids $ids -Verbose
}