$User = gwmi win32_computersystem -Property Username
$UserName = $User.UserName
$TESTDRIVE = Get-PSDrive -Name HKU
If(!$TESTDRIVE){
$Silent = New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
}
If($UserName){
    $UserSplit = $User.UserName.Split(“\”)
    $objUser = New-Object System.Security.Principal.NTAccount($UserSplit[1])
    $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
    $strSID = $strSID.Value
    $OneDrive = 'HKU:\' + $strSID + '\SOFTWARE\Microsoft\OneDrive\Accounts\Business1\Tenants\OneDrive - TriNet HR Corporation\'
    $TestPath = Test-Path -path $OneDrive
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
        $objUser = New-Object System.Security.Principal.NTAccount($LoggedOnUserName)
        $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
        $strSID = $strSID.Value
        $OneDrive = 'HKU:\' + $strSID + '\SOFTWARE\Microsoft\OneDrive\Accounts\Business1\Tenants\OneDrive - TriNet HR Corporation\'
        $TestPath = Test-Path -path $OneDrive
    }
    else{
        Foreach($_ in $LoggedOnUserName){
        $objUser = New-Object System.Security.Principal.NTAccount($_)
        $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
        $strSID = $strSID.Value
        $OneDrive = 'HKU:\' + $strSID + '\SOFTWARE\Microsoft\OneDrive\Accounts\Business1\Tenants\OneDrive - TriNet HR Corporation\'
        $TestPath = Test-Path -path $OneDrive
        }
    }
}
If($TestPath -eq $true){
    Write-Host "Success!"
}