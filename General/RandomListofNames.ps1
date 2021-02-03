<#
.DESCRIPTION
  Randomise a list of names, used for generating a daily stand up order
.NOTES
  Version:        1.0
  Author:         Chris Coombes
  Email:          ccoombes@outlook.com
  Creation Date:  03-02-2021
  Purpose/Change: Initial script development
#>
$Names = "Bart","Homer","Marge","Lisa","Maggie","Moe"
$Names | Sort-Object {Get-Random}