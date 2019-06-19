#Uncomment this and put in the full directory path to "ConfigurationManager.psd1" to make this work.
#import-module .\ConfigurationManager.psd1
import-module 'C:\Program Files (x86)\ConfigMgr\bin\ConfigurationManager.psd1'

#Changes directory to the SCCM Server
CD TRN:
#Specify the collection you want '*' indicates wildcard (no quotes) This will run Machine Policy on the target collection.
Invoke-CMClientNotification -DeviceCollectionName "Dev - JohnP" -NotificationType RequestMachinePolicyNow
        