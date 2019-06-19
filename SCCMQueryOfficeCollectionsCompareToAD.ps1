#            !!!Cannot be ran as Admin!!!
#            !!!Cannot be ran as Admin!!!
#            !!!Cannot be ran as Admin!!!

#Uncomment this and put in the full directory path to "ConfigurationManager.psd1" to make this work.
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 

#Changes directory to the SCCM Server
CD TRN:

#Place it will write data to.
$ADData = "C:\Users\rknight\OneDrive - TriNet HR Corporation\JohnPace\Scripts\For David\ADDescription.txt"

#Specify the collection you want '*' indicates wildcard (no quotes around *)
$Collections = Get-CMCollection -Name "Computers Requiring A Restart"

#For each collection that matches the search it will run.
ForEach($Collection in $Collections){

#This is a list of items that match the search that I don't want to include
    If($Collection.name -ne 'Microsoft Office 2016_16.0.6305.6350' -and $Collection.name -ne 'Microsoft Office 2016_16.0.4266.1001' -and $Collection.name -ne 'Microsoft Office 2010_32bit'){
        #Adds the results to Computers variable
        $Computers = Get-CMCollectionMember -CollectionName $Collection.Name
        #After it adds all computers, searches AD for any computers matching the name.
        Foreach($Computer in $Computers){
            $ADComputer = Get-ADComputer -Identity $Computer.Name -Properties Description,LastLogonDate
            #If the AD search is successful
            if($ADComputer){
                #Writes info to the data file
                $Info = $ADComputer.Name + "|"+ $Collection.Name + "|" + $ADComputer.Description + "|" + $ADComputer.LastLogonDate.ToShortDateString() | Out-File -filepath $ADData -Append
                $Info| Out-File -filepath $ADData -Append
                }
            #If the AD search finds nothing.
            Else{
                $Info = $Computer + "|" + $Collection.Name +"||| Not Found In AD" 
                $Info | Out-File $ADData -Append
                }
        #Clears variables to limit junk entry.
        Clear-Variable -Name Info
        Clear-Variable -Name ADComputer
        }
        #Clears variables so we don't re-search same files.
        Clear-Variable Computers
    }
}
