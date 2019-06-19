Function Enable-WinRM {
Param(
[string]$ComputerName
)
	$result = winrm id -r:$ComputerName 2>$null

	Write-Host	
	if ($LastExitCode -eq 0) {
		Write-Host "WinRM already enabled on" $ComputerName "..." -ForegroundColor green
	} else {
		Write-Host "Enabling WinRM on" $ComputerName "..." -ForegroundColor red
		C:\Users\jwpace\Desktop\tools\PSTools\psexec.exe -accepteula \\$ComputerName -s C:\Windows\system32\winrm.cmd qc -quiet
		if ($LastExitCode -eq 0) {
			C:\Users\jwpace\Desktop\tools\PSTools\psservice.exe \\$ComputerName restart WinRM 
			$result = winrm id -r:$ComputerName 2>$null
			
			if ($LastExitCode -eq 0) {Write-Host 'WinRM successfully enabled!' -ForegroundColor green}
			#else {exit 1}
		} 
		#else {exit 1}
	}
}

# Enable-winrm