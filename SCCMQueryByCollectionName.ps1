
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
#$Collections = Get-CMCollection -Name "OneDrive - LIR"
#$Collections = Get-CMCollection -Name "Dev - JohnP"
#$Collections = Get-CMCollection -Name "Pilot Users Austin"
#$Collections = Get-CMCollection -Name "All Windows 10 Workstations"
$Collections = Get-CMCollection -Name "Microsoft Office *"
#$Collections = Get-CMCollection -Name 'Adobe Acrobat X Standard'
#$Collections = Get-CMCollection -Name 'App-V5.1_O365_2016_x86_WSkype-VE2j'
#$Collections = Get-CMCollection -Name 'Adobe Acrobat Standard X Required'
###
##
#


##
##

##
##
#Place it will write data to.
#$ADData = "C:\Users\jwpace\Desktop\Delete\ScriptSource\ADDescription.txt"
$ADData = "C:\Users\rknight\OneDrive - TriNet HR Corporation\Temp\OneDrive5-8-17.txt"

#For each collection that matches the search it will run.
ForEach($Collection in $Collections){
#This is a list of items that match the search that I don't want to include
    If($Collection.name -ne 'Microsoft Office 2016_16.0.6305.6350' -and $Collection.name -ne 'Microsoft Office 2016_16.0.4266.1001' -and $Collection.name -ne 'Microsoft Office 2010_32bit'){
        #Adds the results to Computers variable
        $Computers = Get-CMCollectionMember -CollectionName $Collection.Name
        #After it adds all computers, searches AD for any computers matching the name.
        $Computers.Name
        }
        #Clears variables so we don't re-search same files.
        #Clear-Variable Computers
    }

