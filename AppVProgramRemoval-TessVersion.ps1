$Service = (Get-Service -Name AppVClient).Status
$Attempt = 1
While ($Service -ne "Running" -and $Attempt -lt 10){
    Write-host "Service Still Running"
    Start-Service -Name AppVClient
    Sleep -Seconds 3
    $Service = (Get-Service -Name AppVClient).Status
    $Attempt++
}
If ($Attempt -ge 10){
    Write-Host "Failed to Start Service"
    exit
}
$AppVConnectionGroup = Get-AppvClientConnectionGroup -all
if($AppVConnectionGroup){
    ForEach($Group in $AppVConnectionGroup){
        if($Group.Name -ne 'VE2ff_O365_2016_x86_WSkype_Veritas EV 12.0.0.1528'){
            $AppVPackages = $Group.GetPackages()
            $Group
            $AppVPackages
            $Service = (Get-Service -Name AppVClient).Status
            $Attempt = 1
            While($Service -ne "Stopped" -and $Attempt -lt 10){
                Write-host "Service not Stopped"
                Stop-Process -Name AppVClient -Force
                Sleep -Seconds 3
                $Service = (Get-Service -Name AppVClient).Status
                $Attempt++
            }
            If ($Attempt -ge 10){
                Write-Host "Failed to Stop Service"
                exit
                }
            $Group | Remove-AppvClientConnectionGroup -Verbose
            Sleep -Seconds 3
            ForEach($_ in $AppVPackages){
                $_.name
                Get-AppvClientPackage -Name $_.name | Remove-AppvClientPackage
            }
        }

    Clear-Variable AppVPackages
    Clear-Variable Attempt
    }
}
Get-Variable -Exclude PWD,*Preference | Remove-Variable -EA 0
Start-Service -Name AppVClient