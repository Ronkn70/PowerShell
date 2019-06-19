Function AddComputerToSecurityGroup{
    
    Param(
        [String]$SecurityGroup,
        [Array]$Computer,
        [String]$Sleep
        )

    #How many seconds should the script sleep before executing.
    Start-Sleep -s $Sleep

    #Test Computers (Mine and Dev), don't uncomment the two below please.
    #$Computers = 'LT-CND6271CTX,LT-5CG701130D'


    foreach($_ in $Computers.split(',')){
        $ADComp = Get-ADComputer -Identity $_
        $Check =Get-ADGroup $SecurityGroup -Properties Members
        If($Check.Members -notcontains $ADComp.DistinguishedName)
        {Write-Host $_ "WAS NOT HERE BEFORE"
        }
        Add-ADGroupMember $SecurityGroup -Members $ADComp.SamAccountName
        Sleep -Seconds 3
        $ADComp = Get-ADComputer -Identity $_
        $Check =Get-ADGroup $SecurityGroup -Properties Members
        If($Check.Members -notcontains $ADComp.DistinguishedName)
        {Write-Host $_ "WAS NOT HERE AFTER"
        }
    
        #To Remove computer, for testing only.
        <#Remove-ADGroupMember "SCCM_LOCAL_OneDrive" -Members $ADComp.SamAccountName
        $Check =Get-ADGroup "SCCM_LOCAL_OneDrive" -Properties Members
        If($Check.Members -notcontains $ADComp.DistinguishedName)
        {Write-Host "REMOVED"
        }
        #>
    }
}