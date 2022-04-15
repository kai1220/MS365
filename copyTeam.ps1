Import-Module MicrosoftTeams
Import-Module AzureADPreview

Connect-MicrosoftTeams

$session = New-CsOnlineSession
$module = Import-PSSession $session
Get-Command -Module $module | Sort-Object -Property Noun

# New-Team -DisplayName "<TeamName>" -Visibility <Private/Public> -Description "<description>" -MailNickname "<Nickname/Alias>"


Get-Team -Displayname "<TeamName>"
Get-Team -Displayname "Proj.-Team: Formate 01.10.2021"
Get-Team -DisplayName "Proj.-Team: Formate 01.10.2021" | Get-TeamUser


# Add-TeamUser -GroupId <GroupId>  -User <UserMailAdresse> -Role <owner/member>



# org. Team
# "Proj.-Team: Formate 01.10.2021"
# new team
# "Proj.-Team: Umsetzung NZV / MaKo 2022 "


New-Team -DisplayName "Proj.-Team: Umsetzung NZV / MaKo 2022 " -Visibility Private -Description "Proj.-Team: Umsetzung NZV / MaKo 2022 " -MailNickname "ProjTeamUmsetzungNZVMaKo2022"

# Get-Team -DisplayName "Proj.-Team: Formate 01.10.2021" | Get-TeamUser | Add-TeamUser -GroupId 9969d9a4-756f-43e0-ab49-d2aaed0683ab

Get-Team -DisplayName "Proj.-Team: Umsetzung NZV / MaKo 2022 " | Get-TeamUser

$datum=Get-Date -Format yyyyMMdd
$TeamUsers=Get-Team -DisplayName "Proj.-Team: Formate 01.10.2021" | Get-TeamUser
foreach ($user in $TeamUsers) {                                
                                 
                                if ($user.Role -ne "guest") {
                                                           Get-Team -DisplayName "Proj.-Team: Umsetzung NZV / MaKo 2022 " | Add-TeamUser -User $user.User -Role $user.Role
                                                           Write-Host "Der User: " $user.User "wurde erfolgreich kopiert."
                                }
                                 
 
                                else {
                                Write-Host "Der User: " $user.User "konnte nicht kopiert werden. Er ist ein Gastuser"
                                echo $user.User | Out-File -FilePath "C:\temp\$datum-NonCopiedTeamUser.txt" -Append
                                }
                               }