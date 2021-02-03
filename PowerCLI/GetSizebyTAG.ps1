get-vm -Tag "VeeamTesting" | select name,@{n="OS";e={$_.guest.osfullname}},@{n='UsedSpaceGB'; e={[math]::round($_.usedspacegb,2)}},vmhost | export-csv c:\temp\veeamvms.csv -NoTypeInformation
