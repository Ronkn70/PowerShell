<#	
	.NOTES
#===========================================================================
	Created by:   	Ron Knight
	Date:           01.02.2020
	Organization: 	Builders First Source
	Version:        1
	Filename:    ChromeUpdateStop.ps1
#===========================================================================
	.DESCRIPTION
		This script adds the reg keys so that Google Chrome doesn't autoupdate
	
	Revision Notes:
#>

#===========================================================================
#Set Variables for script
$AppName = "Chrome Reg Hack" #Name of application as it will appear on the log
$LogPath = "C:\temp\BFSlogs" #location of log file
$LogDate = get-date -format "MM-d-yy"

#===========================================================================
#Begin Logging Script
if (!(test-path C:\temp\BFSlogs))
{
	New-Item -ItemType Directory -Path C:\temp\BFSlogs -Verbose
}
else { }
Start-Transcript -Path "$LogPath\$AppName.$LogDate.log" -Force -Append

#===========================================================================
Write-Output "### Script Start ###"
Write-Output "Start time: $(Get-Date)"
Write-Output "Username: $(([Environment]::UserDomainName + "\" + [Environment]::UserName))"
Write-Output "Hostname: $(& hostname)"

#===========================================================================
Write-Output "Modifying Registry"
New-Item -Path "HKLM:\SOFTWARE\Policies\Google\Update" -Name \Privileged –Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Update" -Name “AutoUpdateCheckPeriodMinutes” -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Update" -Name “DisableAutoUpdateChecksCheckboxValue” -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Update" -Name “UpdateDefault” -Value 0

Write-Output "$AppName Install Complete"
# ===========================================================================
Stop-Transcript