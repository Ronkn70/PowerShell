#Checks if Onedrive is already installed.
$OneDrive = Test-Path $env:LOCALAPPDATA'\Microsoft\OneDrive\OneDrive.exe'
if(!$OneDrive){
#If not installed then it installs onedrive
Start-Process -FilePath 'OneDriveSetup.exe' -ArgumentList /silent -Wait
}
#Checks to make sure onedrive installed. If it isn't installed in 50 seconds at this point it quits out.
$OneDrive = Test-Path $env:LOCALAPPDATA'\Microsoft\OneDrive\OneDrive.exe'
While(!$OneDrive){
$OneDrive = Test-Path $env:LOCALAPPDATA'\Microsoft\OneDrive\OneDrive.exe'
$Attempt++
Sleep -Seconds 5
    If($Attempt -ge 10){
    Exit}
}
#This is the install command for configuring onedrive.
#Start-Process $env:LOCALAPPDATA'\Microsoft\OneDrive\OneDrive.exe' -argumentlist '/configure_business:67b039ac-f578-42c6-9b5b-aa1b5bb0388f'
#Copies the onedrive config to a known folder.
Copy-Item OneDriveConfig.ps1 -Destination $env:ProgramData\OneDriveConfig.ps1 -Force
Copy-Item SilentVBS.vbs -Destination $env:ProgramData\SilentVBS.vbs -Force


#Creates a task schedule, will start 1 minute after the time is checked and repeat every hour for 14 days.
$time = (get-date).AddMinutes(1).ToString("HH:mm")
$Name = "OneDriveInstallSCCM"
$TaskCheck = Get-ScheduledTask -TaskName $Name
if($TaskCheck.TaskName -eq $Name){
Unregister-ScheduledTask -TaskName $Name  -Confirm:$false
}
$Action = New-ScheduledTaskAction -Execute '%programdata%\SilentVBS.vbs'
$Trigger = New-ScheduledTaskTrigger -once -at $time -RepetitionDuration  (New-TimeSpan -Days 14)  -RepetitionInterval  (New-TimeSpan -Minutes 60)
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -ExecutionTimeLimit 01:00:00)
$Task | Register-ScheduledTask -TaskName $Name