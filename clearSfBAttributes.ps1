Import-Module MicrosoftTeams
Import-Module AzureADPreview
Import-Module ActiveDirectory

$session = New-CsOnlineSession
$module = Import-PSSession $session
Get-Command -Module $module | Sort-Object -Property Noun



# AD auslesen

Import-Module ActiveDirectory
Get-ADObject -LDAPFilter “(msRTCSIP-PrimaryHomeServer=*)”



# Clear-Befehl
# Get-ADObject -LDAPFilter “(msRTCSIP-PrimaryHomeServer=*)” | ForEach-Object {Set-ADObject -Identity $_.DistinguishedName -Clear “msRTCSIP-DeploymentLocator”, “msRTCSIP-FederationEnabled”, “msRTCSIP-InternetAccessEnabled”, “msRTCSIP-OptionFlags”, “msRTCSIP-PrimaryUserAddress”, “msRTCSIP-UserEnabled”, “msRTCSIP-UserPolicies”, “msRTCSIP-UserRoutingGroupId”, “msRTCSIP-PrimaryHomeServer”; “Cleaned $($_)”}




# Neues Team anlegen:
Get-Team -DisplayName "Proj.-Team: Formate 01.04.2021"
# New-Team -DisplayName "Proj.-Team: Formate 01.10.2021" -Visibility Private -Description "Proj.-Team: Formate 01.10.2021" -MailNickname "Proj.-TeamFormate01.10.2021"

# Parameter ändern
Get-Team -DisplayName "Proj.-Team: Formate 01.10.2021" | Set-Team -MailNickname "Proj.-TeamFormate01.10.2021"


# User auslesen (Standard)
Get-TeamUser -GroupId e77bb320-4578-4f03-a9dd-4d2564ad56d8
# alt.
Get-Team -DisplayName "Proj.-TeamFormate 01.10.2021" | Get-TeamUser

# Wenn keine Gäste im Team sind

$TeamUsers=Get-TeamUser -GroupId e77bb320-4578-4f03-a9dd-4d2564ad56d8
# alt
$TeamUsers=Get-Team -DisplayName "Proj.-Team: Formate 01.04.2021" | Get-TeamUser
# foreach ($user in $TeamUsers) {Add-TeamUser -GroupId 6764dd0e-e51b-472e-8e02-30051e97f4a4 -User $user.User -Role $user.Role}
# alt
# foreach ($user in $TeamUsers) {Get-Team -DisplayName "Proj.-TeamFormate 01.10.2021" | Add-TeamUser -User $user.User -Role $user.Role}


# Wenn keine Gäste im Team sind

$TeamUsers=Get-TeamUser -GroupId e77bb320-4578-4f03-a9dd-4d2564ad56d8 | where {$_.Role -like "*own*"}

# Wenn die GroupID schon bekannt ist:
# foreach ($user in $TeamUsers) {Add-TeamUser -GroupId 6764dd0e-e51b-472e-8e02-30051e97f4a4 -User $user.User -Role Owner}

# Wenn die GroupID noch nicht bekannt ist:
# foreach ($user in $TeamUsers) Get-Team -DisplayName "Proj.-Team: Formate 01.10.2021 | Add-TeamUser -User $user.User -Role Owner}






# oder mit if clause

foreach ($user in $TeamUsers) {
                                if ($user.Role -ne "guest") {
                                                           #Get-Team -DisplayName "Proj.-Team: Formate 01.10.2021 | Add-TeamUser -User $user.User -Role $user.Role
                                                            echo "User"
                                }
                                

                                else {
                                Write-Host "Der User: " $user.User "konnte nicht kopiert werden. Er ist ein Gastuser"

                                Write-Host "Der User: " $user.User "konnte nicht kopiert werden. Er ist ein Gastuser" | Out-File -FilePath C:\temp_kai\CopyTeamsUser.txt -Append
                                 echo $user.User | Out-File -FilePath C:\temp_kai\NonCopiedTeamUser.txt -Append
                                }
                               }








UCDialPlans.com - Dial Plan Tools

https://www.ucdialplans.com/

https://www.myteamslab.com/2019/02/microsoft-teams-direct-routing-tool.html


Test-CsEffectiveTenantDialPlan -DialedNumber #### -Identity <UPN or Object ID> -TenantScopeOnly



