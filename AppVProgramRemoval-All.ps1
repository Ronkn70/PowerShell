Function Remove-AppVConnectionGroupsAll{

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
Start-Service -Name AppVClient


$SpotCheckConnectionGroup = Get-AppvClientConnectionGroup -All
ForEach($_ in $SpotCheckConnectionGroup){
    If($_.Name -like 'Microsoft Office 2016*'){
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
    $_ | Remove-AppvClientConnectionGroup -Verbose
    }
}
$SpotCheckPackage = Get-AppvClientPackage -All
ForEach($_ in $SpotCheckPackage){
    If($_.Name -like 'Microsoft Office 2016*'){
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
    $_ | Remove-AppvClientPackage -Verbose
    }
}

$Results = Get-AppvClientConnectionGroup -All
$Results += Get-AppvClientPackage -All
Write-Output 'Remaining items' , $Results.Name
}