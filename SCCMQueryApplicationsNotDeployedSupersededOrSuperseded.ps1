
#            !!!Cannot be ran as Admin!!!
#            !!!Cannot be ran as Admin!!!
#            !!!Cannot be ran as Admin!!!

#Uncomment this and put in the full directory path to "ConfigurationManager.psd1" to make this work.
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 

#Changes directory to the SCCM Server
CD TRN:

$CMApplications = Get-CMApplication -Fast
$int = 0
ForEach($_ in $CMApplications){
If ($_.NumberOfDeployments -eq 0 -and $_.IsSuperseded -or $_.IsSuperseding -eq 'True'){
Write-Output $_.LocalizedDisplayName
$Int++
}
}
$int