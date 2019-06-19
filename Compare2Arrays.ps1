$VE2J = @('').split(',')
$OD = @('').split(',')
$Results = @()
foreach ($item in $VE2J) {
    if ($OD -contains $item) {
        Write-Output "Do something with $item";
        $Results += $item
    }
}