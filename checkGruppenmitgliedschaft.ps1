Import-Module MicrosoftTeams
Import-Module AzureADPreview
Import-Module ActiveDirectory

Connect-AzureAD

$session = New-CsOnlineSession
$module = Import-PSSession $session
Get-Command -Module $module | Sort-Object -Property Noun

Connect-MsolService
$MsolGroups = Get-MsolGroup -all
# foreach ($Group in $MsolGroups) {Get-MsolGroupMember -GroupObjectId $Group.objectid -All | Where-Object {$_.UserPrincipalName -like "sandra.fischer*"}}
# foreach ($Group in $MsolGroups) {Get-MsolGroupMember -GroupObjectId $Group.objectid -All | Where {$_.DisplayName -like "*sandra*"}}
foreach ($Group in $MsolGroups) {Get-MsolGroupMember -GroupObjectId $Group.objectid -All | Where {$_.EmailAddress -like "sandra.fischer*"}}


$teams = Get-AzureADGroup
foreach ($team in $teams) {Get-AzureADGroupMember -ObjectId $team.objectid | Where-Object {$_.UserPrincipalName -like "sandra.fischer*"}}
# foreach ($team in $teams) {Get-AzureADGroupOwner -ObjectId $team.objectid | Where-Object {$_.UserPrincipalName -like "kai*"}}
