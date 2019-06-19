#Start-Process $env:LOCALAPPDATA'\Microsoft\OneDrive\OneDrive.exe' -argumentlist '/configure_business:67b039ac-f578-42c6-9b5b-aa1b5bb0388f'
Copy-Item OneDriveConfig.ps1 -Destination $env:ProgramData\OneDriveConfig.ps1 -Force
$time = (get-date).AddMinutes(1).ToString("HH:mm")
$Name = "OneDriveInstallSCCM"
Unregister-ScheduledTask -TaskName $Name  -Confirm:$false
$Action = New-ScheduledTaskAction -Execute '%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-NonInteractive -NoLogo -NoProfile -File "%programdata%\OneDriveConfig.ps1"'
$Trigger = New-ScheduledTaskTrigger -once -at $time -RepetitionDuration 3
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings (New-ScheduledTaskSettingsSet)
$Task | Register-ScheduledTask -TaskName $Name
Start-Sleep -Seconds 180