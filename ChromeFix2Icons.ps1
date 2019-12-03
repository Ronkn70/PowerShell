<#	
	.NOTES
#===========================================================================
	Created by:   	Ron Knight
	Date:           11.20.2019
	Organization: 	Builders First Source
	Filename:    Install.ps1
#===========================================================================
	.DESCRIPTION
		This script removes the 2 Chrome shortcuts that appear on the taskbar after a reboot and leaves the good one.
#>

$LogPath = "C:\temp\BFSlogs"
$LogDate = get-date -format "MM-d-yy"

#===========================================================================
#Begin Logging Script
Start-Transcript -Path "$LogPath\ChromeFix2Icons_$LogDate.log" -Force -Append
Write-Output "**********************"
Write-Output 'This script prevents the Chrome double icons on the taskbar.'
Write-Output "**********************"
Write-Output "### Script Start ###"
Write-Output "Start time: $(Get-Date)"
Write-Output "Username: $(([Environment]::UserDomainName + "\" + [Environment]::UserName))"
Write-Output "Hostname: $(& hostname)"
Write-Output "**********************"


#Set variables for Reg keys
$x86Key = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{8A69D345-D564-463c-AFF1-A69D9E530F96}'
$x64Key = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Active Setup\Installed Components\{8A69D345-D564-463c-AFF1-A69D9E530F96}"

If (Get-ItemProperty -Path $x86key -ErrorAction SilentlyContinue) {

    Write-Output 'x86 Value exists'
    Write-Output 'Deleting x86 Reg Key'
    Remove-Item -Path $x86Key
    Start-Process -filepath msiexec.exe -ArgumentList /x {D1D5485F-976F-3417-9BC5-316A616F7F60} /q
    Write-Output "**********************"
} Else {

    Write-Output 'x86 Value DOES NOT exist.'
    Write-Output "**********************"
}


If (Get-ItemProperty -Path $x64key -ErrorAction SilentlyContinue) {

    Write-Output 'x64 Value exists'
    Write-Output 'Deleting x64 Reg Key'
    Remove-Item -Path $x64Key

} Else {

    Write-Output 'x64 Value DOES NOT exist.'
    Write-Output "**********************"
}

Write-Output 'Editing LayoutModification.xml for every user on machine'
$users = get-childitem c:\users
foreach ($user in $users) {
    
        Write-Output "**********************"
        Write-Output "Checking for extra Chrome Taskbar Shortcut for $User "
        Write-Output "**********************"
        If (test-path "C:\Users\$user\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Google Chrome *2*.lnk")
        {
            Write-Output 'Extra Chrome shortcut located.'
            Write-Output 'Manually removing Chrome shortcut from Taskbar'
            Remove-Item -path "C:\Users\$user\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\taskbar\Google Chrome *2*"
            Write-Output "Extra Shortcut Removed from $user taskbar"
        } Else {
            Write-Output "Extra Chrome shortcut not found..."
        }

    Write-Output "Beginning XML fix for $User"
    If (Test-Path 'C:\Users\$user\AppData\Local\Microsoft\Windows\Shell\$text' -PathType Any) {
        Write-Output 'Editing xml for $user'
        $folder = "C:\Users\$user\AppData\Local\Microsoft\Windows\Shell"
        $text = ".\LayoutModification.xml"
        Get-Content $text | Where-Object {$_ -notmatch "Google Chrome.lnk"} | Set-Content "Layout2.xml"
        Rename-Item -path "$Folder\LayoutModification.xml" -NewName "LayoutModification2.xml.old"
        Rename-Item -path "$Folder\Layout2.xml" -NewName "$text"
        Remove-Item -path "$Folder\LayoutModification2.xml.old"
        Write-Output 'Finished editing xml for $user'
    }
}
Write-Output "**********************"
Write-Output 'Script Complete.'
#===========================================================================
Stop-Transcript
exit 0
