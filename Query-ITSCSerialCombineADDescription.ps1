$SourceData = "C:\Users\jwpace\Desktop\Delete\ScriptSource\ListOfComputers.txt"
$ADData = "C:\Users\jwpace\Desktop\Delete\ScriptSource\ADDescription.txt"

$ListofComputers = get-content  $SourceData
#$ListofComputers = '31KW7W1'
        Foreach($Computer in $ListofComputers){
            $Computer = '*'+ $Computer
            $ADComputers = Get-ADComputer -filter {name -like $Computer} -Properties Description,LastLogonDate,whenCreated,Operatingsystem,DistinguishedName
            if($ADComputers){
                ForEach($ADComputer in $ADComputers){
                   If($ADComputer.Description){
                        $ADUser = Get-ADUser -Filter 'Name -eq $ADComputer.Description' -Properties SamAccountName
                        $Info = $ADComputer.Name + "|"+ $ADComputer.Description + "|" + $ADComputer.OperatingSystem + "|" + $ADComputer.LastLogonDate.ToShortDateString() + "|"<# + $ADComputer.DistinguishedName + "|"#> + $ADUser.SamAccountName + "|" + $Computer
                    }
                    else{
                        $Info = $ADComputer.Name + "|"+ $ADComputer.Description + "|" + $ADComputer.OperatingSystem + "|"  + $ADComputer.LastLogonDate.ToShortDateString() <#  + "|" + $ADComputer.DistinguishedName #> + "|" + $Computer
                    }
                    $Info| Out-File -filepath $ADData -Append
                    }
                }
            Else{
                $Info = $Computer +"||| Not Found In AD" 
                $Info | Out-File $ADData -Append
            }
        Clear-Variable -Name Info -ErrorAction SilentlyContinue
        Clear-Variable -Name ADComputer -ErrorAction SilentlyContinue
        Clear-Variable -Name ADUser -ErrorAction SilentlyContinue
        }