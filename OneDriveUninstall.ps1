$LocalApdataOneDrive = $env:LOCALAPPDATA+'\Microsoft\OneDrive\'
$Files = Get-ChildItem -path $LocalApdataOneDrive -Name OneDriveSetup.exe -Recurse
ForEach($File in $Files){
If($File -notlike 'Update*'){
Start-Process ($LocalApdataOneDrive+$File) -argumentlist '/uninstall' -Wait
}
}
#OneDrive Uninstall
#Start-Process $env:LOCALAPPDATA'\Microsoft\OneDrive\17.3.6720.1207\OneDriveSetup.exe' -argumentlist '/uninstall'