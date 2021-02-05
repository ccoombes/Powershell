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
get-vm -Tag "VeeamTesting" | select name,@{n="OS";e={$_.guest.osfullname}},@{n='UsedSpaceGB'; e={[math]::round($_.usedspacegb,2)}},vmhost | export-csv c:\temp\veeamvms.csv -NoTypeInformation
