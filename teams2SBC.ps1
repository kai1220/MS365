#WICHTIG#
### es werden auch die SkypeForBusiness Admin Rollen benötigt, sonst funktioniert Set-csUser nicht richtig ###


Import-Module MicrosoftTeams
Import-Module AzureADPreview

Connect-MicrosoftTeams
Get-Command -Module MicrosoftTeams | Sort-Object -Property Noun



# Dienst konfigurieren: Richtlinien anpassen, Einstellungen verändern: Erweiterung für SkypeForBusinessOnline
# mit tenant verbinden:
$session = New-CsOnlineSession
$module = Import-PSSession $session
Get-Command -Module $module | Sort-Object -Property Noun


#alternative
Import-Module -Name MicrosoftTeams
$session = New-CsOnlineSession
Import-PSSession $session





# SBC online nehmen
# user prüfen

# Get-CsOnlineUser -Identity "<User name>" | fl RegistrarPool,OnPremLineUriManuallySet,OnPremLineUri,LineUri
Get-CsOnlineUser -Identity "avayatest1" | fl RegistrarPool,OnPremLineUriManuallySet,OnPremLineUri,LineUri
Get-CsOnlineUser -Identity "Raaben, Michael" | fl RegistrarPool,OnPremLineUriManuallySet,OnPremLineUri,LineUri
Get-CsOnlineUser -Identity "Fuchs, Jonathan" | fl RegistrarPool,OnPremLineUriManuallySet,OnPremLineUri,LineUri

# Set-CsUser -Identity "avayatest1" -OnPremLineURI "tel:+49234960;ext=4523" -EnterpriseVoiceEnabled $true -HostedVoiceMail $true
# Set-CsUser -Identity "Raaben, Michael" -OnPremLineURI "tel:+49234960;ext=2552" -EnterpriseVoiceEnabled $true -HostedVoiceMail $true
# Set-CsUser -Identity "jonathan.fuchs@stadtwerke-bochum.de" -OnPremLineURI "tel:+49234960;ext=4522" -EnterpriseVoiceEnabled $true -HostedVoiceMail $true

# sbc prüfen
# Get-CsOnlinePSTNGateway -Identity sbc.contoso.com 
Get-CsOnlinePSTNGateway -Identity voipteams.ewmr.de





# verschiedene Beispiele

# Set-CsUser -Identity "<User name>" -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI tel:<phone number>
# Set-CsUser -Identity "spencer.low@contoso.com" -OnPremLineURI tel:+14255388797 -EnterpriseVoiceEnabled $true -HostedVoiceMail $true
# Set-CsUser -Identity "spencer.low@contoso.com" -OnPremLineURI tel:+14255388701;ext=1001 -EnterpriseVoiceEnabled $true -HostedVoiceMail $true
# Set-CsUser -Identity "stacy.quinn@contoso.com" -OnPremLineURI tel:+14255388701;ext=1002 -EnterpriseVoiceEnabled $true -HostedVoiceMail $true


# Wählpläne
# https://docs.microsoft.com/de-de/microsoftteams/create-and-manage-dial-plans

#check dialPlans
# Liste aller Pläne inkl. Details
Get-CsTenantDialPlan
# einzelner plan inkl. Details
Get-CsTenantDialPlan -Identity PoC

# Wählplan löschen
Remove-CsTenantDialPlan -Identity PlanName -force

# Effektiven Plan für best. User herausfinden
Get-CsEffectiveTenantDialPlan -Identity "Raaben, Michael"

# Effektiven Plan testen mit best. Nummer
Test-CsEffectiveTenantDialPlan -DialedNumber 54504312 -Identity "Raaben, Michael"






# user einen dialPlan zuweisen
Grant-CsTenantDialPlan -Identity amos.marble@contoso.com -PolicyName RedmondDialPlan

