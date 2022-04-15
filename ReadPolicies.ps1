Import-Module MicrosoftTeams
Import-Module AzureADPreview
Import-Module ActiveDirectory

$session = New-CsOnlineSession
$module = Import-PSSession $session
Get-Command -Module $module | Sort-Object -Property Noun




# alle Mitglieder einer TeamsMeetingPolicy

$Users = Get-CsOnlineUser | Select-Object DisplayName, TeamsMeetingPolicy
$Users | Where-Object TeamsMeetingPolicy -eq "Report_Besprechungsteilnehmer"






# Policytyp abfragen
$meetingPolicies=Get-CsTeamsMeetingPolicy |  Select-Object Identity



$Users | Where-Object TeamsMeetingPolicy - ("RestrictedAnonymousAccess")
$Users | Where-Object TeamsMeetingPolicy -eq $null


foreach ($policy in $meetingPolicies) {
        if ($policy -eq "Global") {
        $Users | Where-Object TeamsMeetingPolicy -eq $null
        }
        else {
        $Users | Where-Object TeamsMeetingPolicy -eq $policy
        }
}


$string1 ="Hurra"
$string2 ="joMan"

foreach ($policy in $meetingPolicies) {
    if ($policy -eq $null){    
    $string1
    }
    else {
    $string2
    }
}

foreach ($policy in $meetingPolicies) {
$policy

}





PS C:\WINDOWS\system32> get-csonlineuser | select-object DisplayName, SipAddress, Hostingprovider, TargetServerIfMoving,EnterpriseVoiceEnabled,EnabledForRichPresence,ExchangeArchivingPolicy,NonPrimaryResource,MNCReady,TeamsVoiceRoute,OnPremLineURIManuallySet,OptionFlags,LineURI,Enabled,TenantId,UserRoutingGroupId,TargetRegistrarPool,VoicePolicy,CallerIdPolicy,CallingLineIdentity,MobilityPolicy,ConferencingPolicy,BroadcastMeetingPolicy,CloudMeetingPolicy,CloudMeetingOpsPolicy,TeamsMeetingPolicy,TeamsCallingPolicy,TeamsInteropPolicy,TeamsMessagingPolicy,TeamsUpgradeEffectiveMode,TeamsUpgradeNotificationsEnabled,TeamsUpgradePolicyIsReadOnly,ModeAndNotifications,TeamsUpgradePolicy,TeamsCortanaPolicy,TeamsOwnersPolicy,TeamsMeetingBroadcastPolicy,TeamsAppPermissionPolicy,TeamsAppSetupPolicy,TeamsCallParkPolicy,TeamsEducationAssignmentsAppPolicy,TeamsUpdateManagementPolicy,TeamsNotificationAndFeedsPolicy,TeamsChannelsPolicy,TeamsSyntheticAutomatedCallPolicy,TeamsTargetingPolicy,TeamsVerticalPackagePolicy,TeamsComplianceRecordingPolicy,TeamsMobilityPolicy,TeamsTasksPolicy,TeamsIPPhonePolicy,TeamsEmergencyCallRoutingPolicy,TeamsNetworkRoamingPolicy,TeamsCarrierEmergencyCallRoutingPolicy,TeamsEmergencyCallingPolicy,TeamsShiftsAppPolicy,TeamsShiftsPolicy,TeamsUpgradeOverridePolicy,TeamsVideoInteropServicePolicy,TeamsWorkLoadPolicy,ClientUpdatePolicy,ClientUpdateOverridePolicy,OnlineVoicemailPolicy,PresencePolicy,VoiceRoutingPolicy,RegistrarPool,DialPlan,TenantDialPlan,IPPhonePolicy,LocationPolicy,ClientPolicy,ClientVersionPolicy,ArchivingPolicy,LegalInterceptPolicy,PinPolicy,CallViaWorkPolicy,GraphPolicy,ExternalAccessPolicy,HostedVoicemailPolicy,UserServicesPolicy,ExperiencePolicy,XForestMovePolicy,PreferredDataLocationOverwritePolicy,AddressBookPolicy,SmsServicePolicy,ExternalUserCommunicationPolicy,ThirdPartyVideoSystemPolicy,CloudVideoInteropPolicy,ApplicationAccessPolicy,OnlineDialOutPolicy,OnlineVoiceRoutingPolicy,OnlineAudioConferencingRoutingPolicy,TeamsSurvivableBranchAppliancePolicy,TeamsAudioConferencingPolicy,TeamsMeetingBrandingPolicy,TeamsVdiPolicy,TeamsTemplatePermissionPolicy,ExUmEnabled,TeamsFeedbackPolicy,TeamsCallHoldPolicy | export-csv -Path C:\temp_kai\rku-users.csv
