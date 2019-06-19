
#            !!!Cannot be ran as Admin!!!
#            !!!Cannot be ran as Admin!!!
#            !!!Cannot be ran as Admin!!!

#Uncomment this and put in the full directory path to "ConfigurationManager.psd1" to make this work.
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 

#Changes directory to the SCCM Server
CD TRN:

$CollectionName = 'SCCM_ProjectSTD'
$SecurityGroup = 'AD\\'+$CollectionName
$RuleName = $SecurityGroup
Sleep -s 1
$Schedule = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Monday -RecurCount 0
New-CMDeviceCollection -Name $CollectionName -LimitingCollectionName "All Workstations" -RefreshType Continuous
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName -QueryExpression "select *  from  SMS_R_System where SMS_R_System.SystemGroupName = '$SecurityGroup'" -RuleName $RuleName.replace('\\','\')

#Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName  -QueryExpression $Query -RuleName 'testtube'
#Get-
#
#-QueryExpression "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System inner join SMS_G_System_TPM on SMS_G_System_TPM.ResourceID = SMS_R_System.ResourceId" -RuleName "TPM Information"