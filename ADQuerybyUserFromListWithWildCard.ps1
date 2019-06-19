$SourceData = "C:\Users\jwpace\Desktop\Delete\ScriptSource\ListOfComputers.txt"
$ADData = "C:\Users\jwpace\Desktop\Delete\ScriptSource\ADDescription.txt"

$ListofComputers = get-content  $SourceData
        Foreach($Computer in $ListofComputers){
                $ADComputers = Get-ADComputer -filter '(Name -like $Computer)' -Properties Description,LastLogonDate,whenCreated,Operatingsystem,DistinguishedName
                ForEach($ADComputer in $ADComputers){
                    if($ADComputer){
                        If($ADComputers.Count -ne 0){ $Duplicate = $Computer 
                        }
                        If($ADComputer.Description){
                            $ADUser = Get-ADUser -Filter 'Name -eq $ADComputer.Description' -Properties SamAccountName
                            $Info = $ADComputer.Name + "|"+ $ADComputer.Description + "|" + $ADComputer.OperatingSystem + "|" + $ADComputer.LastLogonDate.ToShortDateString() + "|"<# + $ADComputer.DistinguishedName + "|"#> + $ADUser.SamAccountName + '|' + $Computer.replace('*','') + '|' + $Duplicate
                        }
                        else{
                            $Info = $ADComputer.Name + "|"+ $ADComputer.Description + "|" + $ADComputer.OperatingSystem + "|"  + $ADComputer.LastLogonDate.ToShortDateString() <#  + "|" + $ADComputer.DistinguishedName #> + '|' + $Computer.replace('*','') + '|' + $Duplicate
                            }
                     }
                            Else{
                                $Info = $Computer +"||| Not Found In AD" 
                        
                            }
                    $Info| Out-File -filepath $ADData -Append
                    }
            
        Clear-Variable -Name Duplicate -ErrorAction SilentlyContinue
        Clear-Variable -Name Info -ErrorAction SilentlyContinue
        Clear-Variable -Name ADComputer -ErrorAction SilentlyContinue
        Clear-Variable -Name ADUser -ErrorAction SilentlyContinue
        }