$User =  @('Alexis Urban,Chris ONeill,Craig Macfarlane,Deborah Walter,Gregory Gaunt,Ian Shanks,Jeffrey Aviles,Jimmy Dennis,John Ramos,Josh Abel,Josh Medeiros,Mike Pfiester,Nathaniel Pawlukiewicz,Pete Redwood,Prabhat Nadimpalli,Ray Mead,Reginald E Kendall,Richard Phelps,Wayne Yingling,Holly Signore,Jim Rogers,Jesse Garcia').split(',')
ForEach($_ in $User){
    $Info = Get-ADUser -filter 'Name -eq $_' -Properties SAMAccountName
    if($Info){
        $Info.SAMAccountName + '|' + $Info.Name
    }
        else{
    $_
    }
    Clear-Variable Info
}