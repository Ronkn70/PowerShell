
#For List Based use the following
<#
$SourceData = "C:\Users\jwpace\Desktop\Delete\ScriptSource\ListOfComputers.txt"
$ADData = "C:\Users\jwpace\Desktop\Delete\ScriptSource\ADDescription.txt"
$User = get-content  $SourceData
#>

$User = 'Alexis Urban'

foreach($_ in ($User).Split(',')){
$Computers =get-adcomputer -filter {description -like $_} -Properties Description,OperatingSystem
    if ($Computers){
        ForEach ($Computer in $Computers){
        $Computer.description + "|" + $Computer.name + "|" + $Computer.OperatingSystem 
        #$ComputerOutput = $Computer.description + "|" + $Computer.name + "|" + $Computer.OperatingSystem 
        #$ComputerOutput | Out-File -filepath $ADData -Append
        #Remove-Variable ComputerOutput
        }
    Remove-Variable Computer -ErrorAction SilentlyContinue
    }
    Else{
        $_ +"||| Not Found In AD" #| Out-File -filepath $ADData -Append
    }
}
    #get-aduser -Filter {Name -like "Manny*"}