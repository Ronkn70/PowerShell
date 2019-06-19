$computerName = 'LT-5CG6185PJZ,LT-5CG6185P51,LT-5CG6185P2P,LT-5CG6185Q6P,LT-5CG6185NSB,LT-5CG6185P7P,LT-5CG6185PLM,LT-5CG6185NWB,LT-5CG6185PH5' 

Function enableWinRM {
	$result = winrm id -r:$global:compName 2>$null

	Write-Host	
	if ($LastExitCode -eq 0) {
		Write-Host "WinRM already enabled on" $global:compName "..." -ForegroundColor green
	} else {
		Write-Host "Enabling WinRM on" $global:compName "..." -ForegroundColor red
		C:\Users\jwpace\Desktop\tools\PSTools\psexec.exe -accepteula \\$global:compName -s C:\Windows\system32\winrm.cmd qc -quiet
        if ($LastExitCode -eq 0) {
			C:\Users\jwpace\Desktop\tools\PSTools\psservice.exe \\$global:compName restart WinRM 
			$result = winrm id -r:$global:compName 2>$null
			
			if ($LastExitCode -eq 0) {Write-Host 'WinRM successfully enabled!' -ForegroundColor green}
			#else {exit 1}
		} 
		#else {exit 1}
	}
}
$computerName = 'LT-5CG6403ST6'
$computerName = $computerName.Split(',')
ForEach($computer in $computerName){
$global:compName = $Computer
$Ping = Test-Connection $Computer -Count 1
If($Ping){
enableWinRM
#exit 0
$results += Invoke-Command -cn $Computer -ScriptBlock {Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*}
$results += Invoke-Command -cn $computer -ScriptBlock {Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*}
# HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
 # HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*
Clear-Variable Ping
}
}

$Results | Where-Object Displayname -Like 'HP Hotkey Support'| Select-Object DisplayName, Publisher, UninstallString,DisplayVersion -Unique
$Results | Where-Object Displayname -Like 'HP Hotkey Support'| Select-Object UninstallString -Unique
#($Results | Select-Object Displayname -Unique).count
#$Results | Select-Object Displayname -Unique |Sort-Object -Property Displayname