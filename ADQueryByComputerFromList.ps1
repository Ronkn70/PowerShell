$SourceData = "C:\Users\jwpace\Desktop\Delete\ScriptSource\ListOfComputers.txt"
$ADData = "C:\Users\jwpace\Desktop\Delete\ScriptSource\ADDescription.txt"

$ListofComputers = get-content  $SourceData
#$ListofComputers = 'LT-31KW7W1'
        Foreach($Computer in $ListofComputers){
            $ADComputer = Get-ADComputer -Identity $Computer -Properties Description,LastLogonDate,whenCreated,Operatingsystem,DistinguishedName
            if($ADComputer){
               If($ADComputer.Description){
                    $ADUser = Get-ADUser -Filter 'Name -eq $ADComputer.Description' -Properties SamAccountName
                    $Info = $ADComputer.Name + "|"+ $ADComputer.Description + "|" + $ADComputer.OperatingSystem + "|" + $ADComputer.LastLogonDate.ToShortDateString() + "|"<# + $ADComputer.DistinguishedName + "|"#> + $ADUser.SamAccountName
                }
                else{
                    $Info = $ADComputer.Name + "|"+ $ADComputer.Description + "|" + $ADComputer.OperatingSystem + "|"  + $ADComputer.LastLogonDate.ToShortDateString() #<  + "|" + $ADComputer.DistinguishedName #>
                }
                $Info| Out-File -filepath $ADData -Append
                }
            Else{
                $Info = $Computer +"||| Not Found In AD" 
                $Info | Out-File $ADData -Append
            }
        Clear-Variable -Name Info
        Clear-Variable -Name ADComputer
        Clear-Variable -Name ADUser
        }