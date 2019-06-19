
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
$Collections = Get-CMCollection -Name "All Windows 10 Workstations"
###
##
#


##
##
#$Collections = Get-CMCollection -Name "Dev - JohnP"
#$Collections = Get-CMCollection -Name "Pilot Users Austin"
##
##

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


#$SearchScopes = "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins"#,"HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\Outlook\Addins"
#$SearchScopes = "HKLM:\SOFTWARE\Microsoft\AppV\Client\PackageGroups\DAE2908F-2F5C-4FB6-9B68-157D2089E68D\Versions\54E54898-2AC2-4B59-81C7-13AEEC1BC5F0\REGISTRY\MACHINE\Software\Wow6432Node\Microsoft\Office\Outlook\Addins"
$SearchScopes = "HKLM:\SOFTWARE\Microsoft\AppV\Client\PackageGroups\*\Versions\*\REGISTRY\MACHINE\Software\Wow6432Node\Microsoft\Office\Outlook\Addins\"
#$SearchScopes = "HKLM:\SOFTWARE\Microsoft\AppV\Client\PackageGroups\"
#$ComputerName = "LT-7ZJ36S1"
#$ComputerName = $env:COMPUTERNAME
$computerName = $computerName.Split(',')
$Results = @()
ForEach($computer in $computerName){
$global:compName = $Computer
$Ping = Test-Connection $Computer -Count 1 -ErrorAction SilentlyContinue
If($Ping){
enableWinRM
#exit 0
#$RegKeys = Invoke-Command -cn $Computer -ScriptBlock {$SearchScopes | % {Get-ChildItem -Path $_ | % {Get-ItemProperty -Path $_.PSPath}}}
$RegKeys = Invoke-Command -cn $Computer -ScriptBlock {param($SearchScopes) $SearchScopes | % {Get-ChildItem -Path $_ -Recurse  | % {Get-ItemProperty -Path $_.PSPath}}} -ArgumentList $SearchScopes
$RegKeysFT = $RegKeys | Select-Object @{n="Name";e={Split-Path $_.PSPath -leaf}},FileName,FriendlyName,Description
ForEach($Item in $RegKeysFT){
#IF($Item.Name -like '*Lync*' -or $Item.Name -like '*Skype*'){
If($Item.FileName){
$FileName = $Item.FileName | ? {$_}
$FileVersion = Invoke-Command -cn $Computer -ScriptBlock {param($FileName) (Get-ChildItem $FileName).VersionInfo} -ArgumentList $FileName -ErrorAction SilentlyContinue
#(Get-ChildItem $FileName).VersionInfo
$Results += $Item.Name + '|' + $Item.FriendlyName + '|' +  $FileName + '|' + $FileVersion.ProductVersion
}
Else{
$Results += $Item.Name + '|' + $Item.FriendlyName + '|' +  '|' + $FileVersion.ProductVersion
}
Clear-Variable FileVersion
}
}
# HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
 # HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*
Clear-Variable Ping
}
#}
Clear-Variable ComputerName

$Results
#$Results | Where-Object Displayname -Like '*AppDesigner*'| Select-Object DisplayName, Publisher, UninstallString,DisplayVersion -Unique
#$Results | Where-Object Displayname -Like '*AppDesigner*'| Select-Object UninstallString -Unique
#($Results | Select-Object Displayname -Unique).count
#$Results | Select-Object Displayname -Unique |Sort-Object -Property Displayname








