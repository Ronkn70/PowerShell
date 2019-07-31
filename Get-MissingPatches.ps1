<#
Get-MissingPatches
Provides a list of missing Windows updates and outputs to a CSV file on the desktop
Ron Knight
07-31-2019
#>

Function Get-MissingPatches {
    get-wmiobject -query "SELECT * FROM CCM_UpdateStatus" -namespace "root\ccm\SoftwareUpdates\UpdatesStore" | where {$_.status -eq "Missing"}
 }

"MISSING UPDATES:" | Out-file -Filepath "C:\Users\$env:USERNAME\Desktop\$env:Computername`_MissingUpdateInfo_$LogDate.csv" -Append
if (Get-MissingPatches -gt 0) {
    Get-MissingPatches | Select-Object Title | Out-file -Filepath "C:\Users\$env:USERNAME\Desktop\$env:Computername`_MissingUpdateInfo_$LogDate.csv" -Append
    }
 Else {
    "NO MISSING UPDATES" | Out-file -Filepath "C:\Users\$env:USERNAME\Desktop\$env:Computername_MissingUpdateInfo_$LogDate.csv" -Append
    }