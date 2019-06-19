
#            !!!Cannot be ran as Admin!!!
#            !!!Cannot be ran as Admin!!!
#            !!!Cannot be ran as Admin!!!

#Uncomment this and put in the full directory path to "ConfigurationManager.psd1" to make this work.
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 

#Changes directory to the SCCM Server
CD TRN:


#
##
###
#Specify the collection you want '*' indicates wildcard (no quotes around *)
#$Collections = Get-CMCollection -Name "Triton AP Endpoint Removal"
$Collections = Get-CMCollection -Name "HP Hotkey Support and Removal"
#$Collections = Get-CMCollection -Name "Dev - JohnP"
#$Collections = Get-CMCollection -Name "Pilot Users Austin"
###
##
#


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

#Place it will write data to.
$ADData = "C:\Users\jwpace\Desktop\Delete\ScriptSource\ADDescription.txt"


#For each collection that matches the search it will run.
ForEach($Collection in $Collections){

#This is a list of items that match the search that I don't want to include
    If($Collection.name -ne 'Microsoft Office 2016_16.0.6305.6350' -and $Collection.name -ne 'Microsoft Office 2016_16.0.4266.1001' -and $Collection.name -ne 'Microsoft Office 2010_32bit'){
        #Adds the results to Computers variable
        $ComputerName += (Get-CMCollectionMember -CollectionName $Collection.Name).Name
        #After it adds all computers, searches AD for any computers matching the name.     
    }
}

$ComputerName = $ComputerName.Split(',')
$int = 0
ForEach($computer in $computerName){
$global:compName = $Computer
$Ping = Test-Connection $Computer -Count 1
Write-Host $Int
$Int++
If($Ping){
enableWinRM
#WMI Query for Installed Software
$InstalledSoftware += Invoke-Command -cn $Computer -ScriptBlock { Get-wmiobject -namespace ‘root\cimv2\sms’ -Class SMS_InstalledSoftware}

#Sorts the Installed software and pulls only the needed information. 

#You can output the text to a .txt file if you wish, just uncomment the last 2 lines and include the destination in the $LogFile portion below.
#$LogFile = "C:\Thisiswhereitgoes.txt"
#$InstalledSoftware | Select-Object -Unique -Property ARPDisplayName,SoftwareCode,ProductVersion,UninstallString | Out-File $LogFile
Clear-Variable Ping
}
}

$InstalledSoftware | Select-Object -Property ARPDisplayName,SoftwareCode,ProductVersion,UninstallString -Unique | Sort-Object -Property ARPDisplayName |Out-String -Width 4096| Out-File -FilePath C:\Users\jwpace\Documents\Reports\InstalledSoftware.csv # -Append
#($Results | Select-Object Displayname -Unique).count
#$Results | Select-Object Displayname -Unique |Sort-Object -Property Displayname