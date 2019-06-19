$UserList = Get-Content C:\Users\jwpace\Desktop\Delete\ScriptSource\UsersList.txt
$WriteData = "C:\Users\jwpace\Desktop\Delete\ScriptSource\ComputersfromDescription"
ForEach($User in $UserList){
    $Computer = Get-ADComputer -filter "Description -eq '$User'" -Properties description
    if($Computer){
        ForEach($_ in $Computer){
            $Info = $_.Description + "|" + $_.Name
            $Info  | Out-File $WriteData -Append
            #Write-Host $Computer.name + $User + $Info
            Clear-Variable Info
        }
        Clear-Variable Computer
    }
    Else{
        $User + "|Not in AD" | Out-File $WriteData -Append

    }
}