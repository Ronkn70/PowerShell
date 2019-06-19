Function Add-UserToSecurityGroup{
        Param(
        [String]$SecurityGroup,
        [Array]$User,
        [String]$Sleep
        )
        
    #How many seconds should the script sleep before executing.
    Start-Sleep -s $Sleep
        
    foreach($_ in $User.split(',')){
        #Adds the user to the group, checks it wasn't there beforehand
        $ADUser = Get-ADUser -filter 'Name -eq $_'
        $Check =Get-ADGroup $SecurityGroup -Properties Members
        If($Check.Members -notcontains $ADUser.DistinguishedName)
        {Write-Host $_ "WAS NOT HERE BEFORE"
        }
        Add-ADGroupMember $SecurityGroup -Members $ADUser.SamAccountName
        
        Sleep -Seconds 3

        #Checks it was added successfully
        $ADUser = Get-ADUser -filter 'Name -eq $_'
        $Check =Get-ADGroup $SecurityGroup -Properties Members
        If($Check.Members -notcontains $ADUser.DistinguishedName)
        {Write-Host $_ "WAS NOT HERE AFTER"
        }
    
        #To Remove computer, for testing only.
        <#Remove-ADGroupMember "SCCM_LOCAL_OneDrive" -Members $ADUser.SamAccountName
        $Check =Get-ADGroup "SCCM_LOCAL_OneDrive" -Properties Members
        If($Check.Members -notcontains $ADUser.DistinguishedName)
        {Write-Host "REMOVED"
        }
        #>
    }
}

Add-UserToSecurityGroup -User 'John Pace' -SecurityGroup 'SCCM_LOCAL_OneDrive' -Sleep 2