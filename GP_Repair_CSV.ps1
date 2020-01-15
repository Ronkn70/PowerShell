<#	
	.NOTES
#===========================================================================
	.Created by:   	Ron Knight
	.Date:          01.03.2020
	.Organization: 	###########
	.Version:       1.0
	.Filename:      RepairGP_csv.ps1
#===========================================================================
	.DESCRIPTION
        This script repairs group policy by detecting a corrupt registry.pol file and renaming it.
        This version is for testing on remote computers and writes the log to a network share.
	
    .EXIT CODES
        0 - Success
        2 - registry.pol does not exist -log off and back on or reboot required.
        3 - registry.pol up to date/not corrupt
        4 - registry.pol could not be renamed

    .REVISION NOTES
#>
#===========================================================================
#Set Variables for script
$AppName = "RepairGroupPolicy" #Name of application as it will appear in the log
$CSVLocation = "\\dalsccmpri01.bfs.buildersfirstsource.com\PKGSource\Group Policy\GP Repair\Logs\results.csv" #Location of CSV file- not used for local version
$LogPath = "\\dalsccmpri01.bfs.buildersfirstsource.com\PKGSource\Group Policy\GP Repair\Logs" #location of log file
$LogDate = get-date -format "MM-dd-yyyy"
$PolPath = "C:\Windows\System32\GroupPolicy\Machine\Registry.pol"
$PCname = "$(& hostname)"
$OS = Get-WmiObject Win32_OperatingSystem
$OSCap = $OS.Caption
$Arch = $OS.OSArchitecture
$OSBuild = $OS.BuildNumber
$ComputerSystem = Get-WmiObject Win32_ComputerSystem
if ($ComputerSystem.Manufacturer -like 'Lenovo') { $Model = (Get-WmiObject Win32_ComputerSystemProduct).Version }
            else { $Model = $ComputerSystem.Model }
$LastLogon = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\').LastLoggedOnUser
$PassFail = "Pass" #Default for good registry. will be changed below as it applies.
#===========================================================================
#Begin Logging Script
Start-Transcript -Path "$LogPath\$PCName.$AppName.$LogDate.log" -Force -Append
#===========================================================================

Write-Output "--==### Script Start ###==--"
Write-Output "Start time: $(Get-Date)"
Write-Output "Username: $(([Environment]::UserDomainName + "\" + [Environment]::UserName))"
Write-Output "Last Logged On User: $lastlogon"
Write-Output "Hostname: $(& hostname)"
Write-Output "Operating System: $OSCap $Arch Build $OSBuild"
Write-Output "Computer Model: $Model"
#===========================================================================

Write-Output "**********************"
Write-Output "Beginning Group Policy repair for $(& hostname)"
Write-Output "**********************"
Write-Output "Testing if Registry.pol exists"

if (!(Test-Path $PolPath)) {
    Write-Output "ERROR: Registry.pol file does not exist."
    Write-Output "Please restart system or have user log off and back on to recreate the Registry.pol file"
    Write-Output "**********************"
    Write-Output "Updating group policy..."
    Invoke-GPUpdate -Force
    Write-Output "Group Policy has been successfully updated."
    Write-Output "**********************"
    $PassFail = "Pass-02"
    Write-Output "Writing results to CSV file"
    $Properties =@{
        ComputerName = "$PCname"
        Date = "$Logdate"
        PassFail = "$PassFail"
        }
    $o = New-Object -TypeName psobject -Property $Properties; $O
    $o | Export-Csv -path FileSystem::"$CSVLocation" -Append
    Write-Output "CSV Location is $CSVLocation"   
    Write-Output "Script completed with exit code 2."
    Write-Output "**********************"
    Stop-Transcript
    Exit 2
} 
Else{
    Write-Output "Registry.pol exists - Continuing repair process..."
    $Poldate = (Get-ChildItem -path C:\Windows\System32\GroupPolicy\Machine\Registry.pol).CreationTime.ToString('ddMMyyyy')
    $PolModDate = (Get-Item "C:\Windows\System32\GroupPolicy\Machine\Registry.pol").LastWriteTime.ToString('ddMMyyyy')
    Write-Output "Registry.pol date $Poldate"
    Write-Output "Last Modified $PolModDate"
    $Isold = ($PolModdate -lt (get-date).add(-30).date)
    <#
    The following detection method is from:
    https://itinlegal.wordpress.com/2017/09/09/psa-locating-badcorrupt-registry-pol-files/
    #>
    if(!(Test-Path -Path $PolPath -PathType Leaf)) { return $null }
    [Byte[]]$FileHeader = Get-Content -Encoding Byte -Path $PolPath -TotalCount 4
    if(($FileHeader -join '') -eq '8082101103') {
    Write-Output "Group Policy is not corrupt."
    Write-Output "**********************"
        if ($Isold -eq 'True') {
            Write-Output "Registry.pol is less than 30 days old"}
            Write-Output "Updating group policy anyway..."
            gpupdate /force
            Write-Output "Group Policy has been successfully updated."
            Write-Output "**********************"
            $PassFail = "Pass-03"
            Write-Output "Writing results to CSV file"
            $Properties =@{
                ComputerName = "$PCname"
                Date = "$Logdate"
                PassFail = "$PassFail"
                }
            $o = New-Object psobject -Property $Properties; $O
            $o | Export-Csv -path FileSystem::"$CSVLocation" -Append
            Write-Output "CSV Location is $CSVLocation"   
            Write-Output "Script completed with exit code 3"
            Stop-Transcript
            Exit 3
         }
        Else {
            Write-output "Registry.pol is older than 30 days. Renaming it to Registry.bak"
            Rename-item -path $PolPath -newname Registry.bak
            Write-Output "Updating group policy..."
            gpupdate /force
            Write-Output "Group Policy has been successfully updated."
            $PassFail = "Pass-00"
            Write-Output "Writing results to CSV file"
            $Properties =@{
                ComputerName = "$PCname"
                Date = "$Logdate"
                PassFail = "$PassFail"
                }
            $o = New-Object psobject -Property $Properties; $O
            $o | Export-Csv -path FileSystem::"$CSVLocation" -Append
            Write-Output "CSV Location is $CSVLocation"  
            Write-Output "Script completed exit code 0"
            Stop-Transcript
        Exit 0
        }
         if(!(Test-Path -Path $PolPath -PathType Leaf)) { return $null }
    [Byte[]]$FileHeader = Get-Content -Encoding Byte -Path $PolPath -TotalCount 4
    if(($FileHeader -join '') -ne '8082101103') {
        Write-Output "Registry is corrupt or has not been updated. Starting repairs..."
        $PassFail = "Corrupt"
        Write-Output "Renaming old Registry.pol file."
        if (!(Test-Path $PolPath)) {
            Write-Output "ERROR: Registry.pol file does not exist."
            Write-Output "Please restart system to recreate the Registry.pol file"
            Write-Output "**********************"
            Write-Output "Updating group policy..."
            Invoke-GPUpdate -Force
            Write-Output "Group Policy has been successfully updated."
            Write-Output "**********************"
            $PassFail = "Pass-02"
            Write-Output "Writing results to CSV file"
            $Properties =@{
                ComputerName = "$PCname"
                Date = "$Logdate"
                PassFail = "$PassFail"
                }
            $o = New-Object psobject -Property $Properties; $O
            $o | Export-Csv -path FileSystem::"$CSVLocation" -Append
            Write-Output "CSV Location is $CSVLocation"
            Write-Output "Script completed exit code 2"
            Stop-Transcript
            Exit 2
        }
        Else {
            Write-Output "Registry.pol exists. Renaming to Registry.bak."
            Rename-item -path $PolPath -newname Registry.bak
            if (!(Test-Path C:\Windows\System32\GroupPolicy\Machine\Registry.bak)) {
                Write-Output "ERROR: Registry.pol has not been renamed. please re-run this script"
                Write-Output "**********************"
                Write-Output "Updating group policy..."
                Invoke-GPUpdate -Force
                Write-Output "Group Policy has been successfully updated."
                Write-Output "ERROR: Exiting with code 4 - Registry.pol not updated"
                Write-Output "Please manually rename $Polpath and restart computer."
                $PassFail = "Fail-04"
                Write-Output "Writing results to CSV file"
                $Properties =@{
                    ComputerName = "$PCname"
                    Date = "$Logdate"
                    PassFail = "$PassFail"
                    }
                $o = New-Object psobject -Property $Properties; $O
                $o | Export-Csv -path FileSystem::"$CSVLocation" -Append
                Write-Output "CSV Location is $CSVLocation"  
                Write-Output "Script completed exit code 4"
            Stop-Transcript
                Exit 4
            }
            Else{
                Write-Output "Success - Registry.BAK has been verified to exist."
                $PassFail = "Pass"
                Write-Output "Writing results to CSV file"
                $Properties =@{
                    ComputerName = "$PCname"
                    Date = "$Logdate"
                    PassFail = "$PassFail"
                    }
                $o = New-Object psobject -Property $Properties; $O
                $o | Export-Csv -path FileSystem::"$CSVLocation" -Append
                Write-Output "CSV Location is $CSVLocation"  
            }
        }
        Write-Output "**********************"
        Write-Output "Updating group policy..."
        invoke-gpupdate -force
        Write-Output "Group Policy has been successfully updated."
        
        Write-Output "**********************"
        Write-Output "Verifying that Registry.pol has been recreated."
        if (!(Test-Path $PolPath)) {
            Write-Output "Registry.pol file does not exist. A system restart may be needed or have the user log off and back on to recreate the file."
        }
        Else {
            Write-Output "Registry.pol has been recreated."
    }
}
    Write-Output "**********************"
    Write-Output "Registry repairs are complete."
}
# ===========================================================================
Write-Output "Script completed with exit code 0"
Stop-Transcript
exit 0