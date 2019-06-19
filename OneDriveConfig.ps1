$SearchKeys = (Get-ChildItem HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\).name.trim()
$SearchKeys = $SearchKeys.replace('HKEY_CURRENT_USER','HKCU:')
ForEach($Keys in $SearchKeys){
    $Values = Get-ItemProperty -path $Keys
    If($Values.ConfiguredTenantId -eq '67b039ac-f578-42c6-9b5b-aa1b5bb0388f'){
        $Compliant = $True
    }
}
If($Compliant -eq $True){
    Write-Output "Compliant"
    New-Item -Name ONEDRIVECONFIGURED -Path $env:ProgramData\ -Force
}
Else{
    $User = gwmi win32_computersystem -Property Username
    $UserName = $User.UserName
    If($UserName){
        $UserSplit = $User.UserName.Split(“\”)
        $OneDrive = “$env:SystemDrive\users\” + $UserSplit[1] +“\appdata\local\microsoft\onedrive\onedrive.exe”
        $TestPath = Test-Path $OneDrive
    }
    Else{
        $LoggedOnUsers = Get-WmiObject -Class Win32_LoggedOnUser
        Foreach($_ in $LoggedOnUsers){
            if($_.Antecedent -like '\\.\root\cimv2:Win32_Account.Domain="AD",Name="*'){
            $LoggedOnUserName += "|" + $_.Antecedent
            }
        }
        $LoggedOnUserName = $LoggedOnUserName.Split('|')
        $LoggedOnUserName = ($LoggedOnUserName.replace('\\.\root\cimv2:Win32_Account.Domain="AD",Name="',"")).replace('"','')
        $LoggedOnUserName = $LoggedOnUserName.trim()
        $LoggedOnUserName = $LoggedOnUserName | select -uniq
        $LoggedOnUserName = $LoggedOnUserName | ? {$_}  
        if($LoggedOnUserName.count -eq 1){
            $OneDrive = “$env:SystemDrive\users\” + $LoggedOnUserName +“\appdata\local\microsoft\onedrive\onedrive.exe”
            $TestPath = Test-Path $OneDrive
        }
        else{
            Foreach($_ in $LoggedOnUserName){
            $OneDrive = “$env:SystemDrive\users\” + $_ +“\appdata\local\microsoft\onedrive\onedrive.exe”
            $TestPath = Test-Path $OneDrive
            }
        }
    }
    If($TestPath){
        Start-Process $OneDrive -argumentlist '/configure_business:67b039ac-f578-42c6-9b5b-aa1b5bb0388f'
    }
}