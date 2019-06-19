$DaysInactive = 365
$time = (Get-Date).Adddays(-($DaysInactive)) 
  
# Get all Workstation OU computers with lastLogonTimestamp less than our time 
$Results1 = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -SearchBase 'OU=workstations,DC=ad,DC=corp,DC=local' -Properties LastLogonTimeStamp | 
  
# Output hostname and lastLogonTimestamp into CSV 
select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} #| export-csv OLD_Computer.csv -notypeinformation
$Results1.Count

# Get all AD computers with lastLogonTimestamp less than our time 
$Results2 = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -SearchBase 'DC=ad,DC=corp,DC=local' -Properties LastLogonTimeStamp | 
  
# Output hostname and lastLogonTimestamp into CSV 
select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} #| export-csv OLD_Computer.csv -notypeinformation
$Results2.Count
$Results2.count - $Results1.count