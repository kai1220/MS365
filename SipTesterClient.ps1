<#
.SYNOPSIS
    SIP Tester Client

.DESCRIPTION
    This script submits SIP test to PSTN Inspector, waits for final result, and presents the result in a human-readable format.
    Note that this script will prompt the user for credentials which are needed for Azure AD authentication on PSTN Inspector.

    This script needs Adal.ps package for execution. If it's not present then script will try to install it automatically.
    For this, run this script in administrator mode (first execution only).

    Call flow common to all tests:
	* Outbound call is placed by TeamsOut user to a number specified in the DestinationNumber.
	* SBC receives INVITE and places outbound call back to TeamsIn user's phone number.
	* Call to TeamsIn user is accepted.
	* Media is played/recorded in sequence both ways and validated that is not empty.

    Important considerations about TeamsOut and TeamsIn* users:
    * It's recommended that users are in different tenants (all TeamsIn* users might be in the same tenant though).
        This shouldn't require special configuration on the PSTN partner's SBC being tested and therefore more closely replicates a real-life call flow.
        In this case, DestinationNumber and all TeamsIn* users' IncomingNumbers are real numbers assigned to respective users in the Teams backend.
    * These users might be in the same tenant in which case additional configuration is required on the PSTN partner's SBC being tested.
        Specifically, DestinationNumber and all TeamsIn* users' IncomingNumbers must not be assigned to users in the Teams backend but rather contain
        special prefixes/suffixes that the SBC being tested will strip and route the calls back to Teams.
        As an example, if TeamsIn user's assigned phone number is +5550175, message manipulation and routing rules can be set up on the SBC
        to route calls placed to +4255550175 back to Teams and to +5550175.

    Each test run is represented in the output as a series of rows. Each row indicates the result of the call made as part of the test:
    * Flow - call direction relative to Teams backend, outbound or inbound
    * SipCallId - SIP call ID of SBC being tested
    * Code - call result code, 0 for success, non-0 for failure (internal to Teams backend)
    * TrunkFqdn - the actual SBC used for the test
    * ChainId - the internal Teams call ID
    * State - succeeded or failed
    * Phrase - arbitrary phrase indicating the reason for failure if any

    This script returns True value if test passes, False value if test fails.

.PARAMTER TeamsOutUsername
    Username of caller in Teams (used to make outbound call)

.PARAMETER TeamsOutPassword
    Password of caller in Teams (used to make outbound call)

.PARAMETER TeamsInUsername
    User principal name of the recipient of the call in Teams (used to receive inbound call).

.PARAMETER TeamsInPassword
    Password of the recipient of the call in Teams (used to receive inbound call)

.PARAMETER DestinationNumber
    PSTN number that is routed to TeamsIn user

.PARAMETER TeamsOutDataCenter
    (Optional) Preferred location of Teams client (used to make outbound call), valid values: [APAC-SG, APAC-HK, EMEA-DB, EMEA-AM, NOAM-BL, NOAM-DM]

.PARAMETER TeamsInDataCenter
    (Optional) Preferred location of Teams client (used to receive inbound call), valid values: [APAC-SG, APAC-HK, EMEA-DB, EMEA-AM, NOAM-BL, NOAM-DM]

.PARAMETER TeamsInEscalationUsername
    (Optional) User principal name of the escalation target in Teams (used to escalate call)

.PARAMETER TeamsInEscalationPassword
    (Optional) Password of the escalation target in Teams (used to escalate call)

.PARAMETER TeamsInEscalationIncomingNumber
    (Optional) PSTN number that is routed to TeamsInEscalation user

.PARAMETER TeamsInEscalationDataCenter
    (Optional) Preferred location of Teams client (used to escalate call), valid values: [APAC-SG, APAC-HK, EMEA-DB, EMEA-AM, NOAM-BL, NOAM-DM]

.PARAMETER TeamsInTransferTargetUsername
    (Optional) User principal name of the transfer target in Teams (used to transfer call)

.PARAMETER TeamsInTransferTargetPassword
    (Optional) Password of the transfer target in Teams (used to tranfer call)

.PARAMETER TeamsInTransferTargetIncomingNumber
    (Optional) PSTN number that is routed to TeamsInTransferTarget user

.PARAMETER TeamsInTransferTargetDataCenter
    (Optional) Preferred location of Teams client (used to transfer call), valid values: [APAC-SG, APAC-HK, EMEA-DB, EMEA-AM, NOAM-BL, NOAM-DM]

.PARAMETER TeamsInSimulringUsername
    (Optional) User principal name of the simultaneous ring target Teams (used for simultaneous ring)

.PARAMETER TeamsInSimulringPassword
    (Optional) Password of the simultaneous ring target Teams (used for simultaneous ring)

.PARAMETER TeamsInSimulringIncomingNumber
    (Optional) PSTN number that is routed to TeamsInSimulring user

.PARAMETER TeamsInSimulringDataCenter
    (Optional) Preferred location of Teams client (used for simultaneous call), valid values: [APAC-SG, APAC-HK, EMEA-DB, EMEA-AM, NOAM-BL, NOAM-DM]

.PARAMETER CertificateContent
    Base64 Certificate content for authentication

.PARAMETER ProviderId
    (Optional) Used to verify call records for BV users

.PARAMETER CallDurationMinutes
    Duration of the call in minutes

.PARAMETER MediaValidationFrequencyMinutes
    Frequency of media validation during call in minutes

.PARAMETER HideTable
    (Optional) Won't print out table of test results.

.PARAMETER UseUserCredentials
    (Optional) Uses TeamsOut credentials for authentication.

.EXAMPLE
    .\SipTesterClient.ps1 -TeamsOutUsername user1 -TeamsOutPassword pass1 -TeamsInUsername user2 -TeamsInPassword pass2 -DestinationNumber +12345
    .\SipTesterClient.ps1 -TeamsOutUsername user1 -TeamsOutPassword pass1 -TeamsInUsername user2 -TeamsInPassword pass2 -DestinationNumber +12345 -TeamsInSimulringUsername user3 -TeamsInSimulringPassword pass3 -TeamsInSimulringIncomingNumber +67890
    .\SipTesterClient.ps1 -TeamsOutUsername user1 -TeamsOutPassword pass1 -TeamsInUsername user2 -TeamsInPassword pass2 -DestinationNumber +12345 -TeamsInTransferTargetUsername user3 -TeamsInTransferTargetPassword pass3 -TeamsInTransferTargetIncomingNumber +67890
    .\SipTesterClient.ps1 -TeamsOutUsername user1 -TeamsOutPassword pass1 -TeamsInUsername user2 -TeamsInPassword pass2 -DestinationNumber +12345 -TeamsInEscalationUsername user3 -TeamsInEscalationPassword pass3 -TeamsInEscalationIncomingNumber +67890
#>

[CmdletBinding()]
Param (
    [Parameter(ParameterSetName="Basic", Mandatory=$True)]
    [Parameter(ParameterSetName="Escalation", Mandatory=$True)]
    [Parameter(ParameterSetName="Transfer", Mandatory=$True)]
    [Parameter(ParameterSetName="Simulring", Mandatory=$True)]
    [string]$TeamsOutUsername,

    [Parameter(ParameterSetName="Basic", Mandatory=$True)]
    [Parameter(ParameterSetName="Escalation", Mandatory=$True)]
    [Parameter(ParameterSetName="Transfer", Mandatory=$True)]
    [Parameter(ParameterSetName="Simulring", Mandatory=$True)]
    [string]$TeamsOutPassword,

    [Parameter(ParameterSetName="Basic", Mandatory=$True)]
    [Parameter(ParameterSetName="Escalation", Mandatory=$True)]
    [Parameter(ParameterSetName="Transfer", Mandatory=$True)]
    [Parameter(ParameterSetName="Simulring", Mandatory=$True)]
    [string]$TeamsInUsername,

    [Parameter(ParameterSetName="Basic", Mandatory=$True)]
    [Parameter(ParameterSetName="Escalation", Mandatory=$True)]
    [Parameter(ParameterSetName="Transfer", Mandatory=$True)]
    [Parameter(ParameterSetName="Simulring", Mandatory=$True)]
    [string]$TeamsInPassword,

    [Parameter(ParameterSetName="Basic", Mandatory=$True)]
    [Parameter(ParameterSetName="Escalation", Mandatory=$True)]
    [Parameter(ParameterSetName="Transfer", Mandatory=$True)]
    [Parameter(ParameterSetName="Simulring", Mandatory=$True)]
    [string]$DestinationNumber,

    [Parameter(ParameterSetName="Basic", Mandatory=$False)]
    [Parameter(ParameterSetName="Escalation", Mandatory=$False)]
    [Parameter(ParameterSetName="Transfer", Mandatory=$False)]
    [Parameter(ParameterSetName="Simulring", Mandatory=$False)]
    [int]$CallDurationMinutes = $null,

    [Parameter(ParameterSetName="Basic", Mandatory=$False)]
    [Parameter(ParameterSetName="Escalation", Mandatory=$False)]
    [Parameter(ParameterSetName="Transfer", Mandatory=$False)]
    [Parameter(ParameterSetName="Simulring", Mandatory=$False)]
    [int]$MediaValidationFrequencyMinutes = $null,

    [Parameter(ParameterSetName="Basic", Mandatory=$False)]
    [Parameter(ParameterSetName="Escalation", Mandatory=$False)]
    [Parameter(ParameterSetName="Transfer", Mandatory=$False)]
    [Parameter(ParameterSetName="Simulring", Mandatory=$False)]
    [string]$TeamsOutDataCenter,

    [Parameter(ParameterSetName="Basic", Mandatory=$False)]
    [Parameter(ParameterSetName="Escalation", Mandatory=$False)]
    [Parameter(ParameterSetName="Transfer", Mandatory=$False)]
    [Parameter(ParameterSetName="Simulring", Mandatory=$False)]
    [string]$TeamsInDataCenter,

    [Parameter(ParameterSetName="Escalation", Mandatory=$False)]
    [string]$TeamsInEscalationDataCenter,

    [Parameter(ParameterSetName="Transfer", Mandatory=$False)]
    [string]$TeamsInTransferTargetDataCenter,

    [Parameter(ParameterSetName="Simulring", Mandatory=$False)]
    [string]$TeamsInSimulringDataCenter,

    [Parameter(ParameterSetName="Escalation", Mandatory=$True)]
    [string]$TeamsInEscalationUsername,

    [Parameter(ParameterSetName="Escalation", Mandatory=$True)]
    [string]$TeamsInEscalationPassword,

    [Parameter(ParameterSetName="Escalation", Mandatory=$False)]
    [string]$TeamsInEscalationIncomingNumber = '',

    [Parameter(ParameterSetName="Transfer", Mandatory=$True)]
    [string]$TeamsInTransferTargetUsername,

    [Parameter(ParameterSetName="Transfer", Mandatory=$True)]
    [string]$TeamsInTransferTargetPassword,

    [Parameter(ParameterSetName="Transfer", Mandatory=$True)]
    [string]$TeamsInTransferTargetIncomingNumber,

    [Parameter(ParameterSetName="Simulring", Mandatory=$True)]
    [string]$TeamsInSimulringUsername,

    [Parameter(ParameterSetName="Simulring", Mandatory=$True)]
    [string]$TeamsInSimulringPassword,

    [Parameter(ParameterSetName="Simulring", Mandatory=$True)]
    [string]$TeamsInSimulringIncomingNumber,

    [string] $EndpointUrl = "https://api.pstnmonitoring.skype.com/v1/sip-tester/test-suites",

    [string]$TestTimeoutInSeconds=180,

    [int]$RetryCount = 0,

    [bool]$RetryOnInternalErrors = $true,

    [bool]$RetryOnExternalErrors = $false,

    [string]$ProviderId = $null,

    [string]$CertificateContent = $null,

    [string]$Environment = $null,

    [Parameter(Mandatory = $false)]
    [switch] $HideTable,

    [Parameter(Mandatory = $false)]
    [switch] $UseUserCredentials
)

Function Get-Response([string]$uri, [string]$method, [PSObject]$body, [string]$token, [System.Security.Cryptography.X509Certificates.X509Certificate2]$certificate) {
    $timeoutSeconds = 60

    $headers = @{
	    'Content-Type' = 'application/json';
    	'Authorization' = 'Bearer ' + $token
    }

    Try {
        $resultBucket = New-Object PSObject

    	$testResult = Invoke-WebRequest -Uri $uri -Headers $headers -Method $method -Body $body -Certificate $certificate -UseBasicParsing -TimeoutSec $timeoutSeconds | select -Expand Content

        $resultBucket | Add-Member -Name 'Success' -MemberType Noteproperty -Value $True
        $resultBucket | Add-Member -Name 'Content' -MemberType Noteproperty -Value $testResult

    }
    catch [System.Net.WebException] {
        $resultBucket | Add-Member -Name 'Success' -MemberType Noteproperty -Value $False
        $resultBucket | Add-Member -Name 'Content' -MemberType Noteproperty -Value $_.Exception.Message
    }
    Catch {
        $resultBucket | Add-Member -Name 'Success' -MemberType Noteproperty -Value $False
        $resultBucket | Add-Member -Name 'Content' -MemberType Noteproperty -Value 'Unspecified Failure'
    }

    $resultBucket
}

Function Run-SIPTest([string]$sipTesterUri, [string]$testBody, [string]$certificateContent) {
    $delayInSeconds = 10

    $authority = "https://login.windows.net/common/oauth2/authorize"
    $resourceUrl = "https://calltester.pstnhub.microsoft.com" #2c08a8c9-c50a-42b6-b954-f4207adc4947
    $clientId = "1950a258-227b-4e31-a9cf-717495945fc2" #Set well-known client ID for AzurePowerShell

    $accessToken = $Null
    $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2

    if ([string]::IsNullOrEmpty($certificateContent)) {
        Write-Verbose "Acquiring AAD token..."
        $response = $null

        Import-Module $adalPackage -RequiredVersion $adalVersion

        if ($UseUserCredentials) {
            $pwd = ConvertTo-SecureString -AsPlainText $TeamsOutPassword -Force
            $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
            $AADcredential = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential" -ArgumentList $TeamsOutUsername,$pwd
            $req = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContextIntegratedAuthExtensions]::AcquireTokenAsync($authContext,$resourceUrl,$clientId,$AADcredential)
            $response = $req.Result
        } else {
            $response = Get-ADALToken -Resource $resourceUrl -ClientId $clientId -Authority $authority
        }

        $accessToken = $response.AccessToken
        Write-Verbose "Acquiring AAD token...DONE"
    } else {
        $certificate.Import([Convert]::FromBase64String($certificateContent))
    }


    Write-Verbose "Enqueueing test..."
    $enqueueResult = Get-Response $sipTesterUri POST $testBody $accessToken $certificate

    if (!$enqueueResult.Success) {
        Write-Error "Enqueueing test...FAILED: $($enqueueResult.Content)"
        return $null
    }
    Write-Verbose "Enqueueing test...DONE"

    $enqueueContent = $enqueueResult.Content | ConvertFrom-Json
    $statusLink = $enqueueContent.links.status

    Write-Verbose "Test status link: $statusLink"
    Write-Verbose "Checking test status..."

    do {
        $statusResult = Get-Response $statusLink GET $null $accessToken $certificate # null body
        $statusResult | Add-Member -Name 'BatchId' -MemberType Noteproperty -Value '<Unknown>'

        if (!$statusResult.Success) {
            Write-Verbose "Checking test status...FAILED: $($statusResult.Content)"
            return $statusResult
        }

        $statusContent = $statusResult.Content | ConvertFrom-Json

        $lastResult = $statusContent.tests[0].lastResult

        if ($lastResult.state -eq 'failed' -or $lastResult.state -eq 'succeeded') {
            $statusResult.BatchId = $lastResult.batchId
            return $statusResult
        }

        Write-Verbose "Test in '$($lastResult.state)' state; Checking again in $delayInSeconds seconds..."

        Start-Sleep -Seconds $delayInSeconds
    } while($True)

}

Function ValidatePhoneNumber ([string]$number, [string]$object) {
    if ('' -ne $number -and !($number  -match "^\+?[0-9]+$")) {
        Write-Error "$object is not well-formed"
        throw "Not a valid phone number. Phone number must contain digits only and optional leading plus."
    }
}

ValidatePhoneNumber $DestinationNumber "DestinationNumber"
ValidatePhoneNumber $TeamsInEscalationIncomingNumber "TeamsInEscalationIncomingNumber"
ValidatePhoneNumber $TeamsInTransferTargetIncomingNumber "TeamsInTransferTargetIncomingNumber"
ValidatePhoneNumber $TeamsInSimulringIncomingNumber "TeamsInSimulringIncomingNumber"

$testTitles = @{
    "Basic" = "Outbound to Inbound";
    "Escalation" = "Media Escalation";
    "Simulring" = "Simultaneous Ring";
    "Transfer" = "Consultative Transfer";
}

#Install the ADAL.PS package if it's not installed.
$adalPackage = "ADAL.PS"
$adalVersion = "3.19.8.1"
if(!($CertificateContent) -and !(Get-InstalledModule -Name $adalPackage -RequiredVersion $adalVersion)) {
    Install-Package -Name $adalPackage -RequiredVersion $adalVersion
}

$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$teamsOut = @{username = $teamsOutUsername; password = $teamsOutPassword; dataCenter = $TeamsOutDataCenter}
$teamsIn = @{username = $teamsInUsername; password = $teamsInPassword; incomingNumber = $destinationNumber; dataCenter = $TeamsInDataCenter}
$test = @{teamsOut = $teamsOut; teamsIn = $teamsIn; providerId = $providerId}

if ($CallDurationMinutes){
    $test.Add("callDurationMinutes", $CallDurationMinutes)
}
if ($MediaValidationFrequencyMinutes) {
    $test.Add("mediaValidationFrequencyMinutes", $MediaValidationFrequencyMinutes)
}
if ($Environment) {
    $test.Add("environment", $Environment)
}

switch ($PSCmdlet.ParameterSetName)
{
    "Escalation"{
        $additionalParams = @{username = $TeamsInEscalationUsername; password = $TeamsInEscalationPassword; dataCenter = $TeamsInEscalationDataCenter}
	if('' -ne $TeamsInEscalationIncomingNumber) {
		$additionalParams.Add("incomingNumber", $TeamsInEscalationIncomingNumber)
	}
        $test.Add("teamsInEscalation", $additionalParams)
    }
    "Transfer"{
        $additionalParams = @{username = $TeamsInTransferTargetUsername; password = $TeamsInTransferTargetPassword; incomingNumber = $TeamsInTransferTargetIncomingNumber; dataCenter = $TeamsInTransferTargetDataCenter }
        $test.Add("teamsInTransferTarget", $additionalParams)
    }
    "Simulring"{
        $additionalParams = @{username = $TeamsInSimulringUsername; password = $TeamsInSimulringPassword; incomingNumber = $TeamsInSimulringIncomingNumber; dataCenter = $TeamsInSimulringDataCenter}
        $test.Add("teamsInSimulring", $additionalParams)
    }
}

$tests = @{timeoutSeconds = $testTimeoutInSeconds; tests = @($test)}

if ($RetryCount -gt 0){
    $retryPolicy = @{maxRetries = $RetryCount; retryOnInternalErrors = $RetryOnInternalErrors; retryOnExternalErrors = $RetryOnExternalErrors}
    $tests.Add("retryPolicy", $retryPolicy)
}

$testBody = $tests | ConvertTo-Json -Depth 20

$statusResult = Run-SIPTest $EndpointUrl $testBody $CertificateContent

Function CreateTable ([string]$prefix, [PSCustomObject]$result) {
    $table = [PSCustomObject]@{}
    $result.PSObject.Properties | ForEach-Object {
        $table | Add-Member -Name ($prefix + "." + $_.Name) -MemberType Noteproperty -Value $_.Value
    }
    return $table
}

Function WriteTable([PSCustomObject]$table) {
    if ($table -ne $null) {
        Write-Host (($table | Select -Property * -ExcludeProperty callSetupTimeMs) | Format-Table -AutoSize | Out-String -Width 4000).Trim()
        Write-Host "`r`n"
    }
}

if($null -ne $statusResult) {

    $statusContent = $statusResult.Content | ConvertFrom-Json
    $lastResult = $statusContent.tests[0].lastResult

    Write-Verbose "Test in '$($lastResult.state)' state"

    $lastResult.teamsOut | Add-Member -Name 'flow' -MemberType Noteproperty -Value 'outbound'
    $lastResult.teamsIn | Add-Member -Name 'flow' -MemberType Noteproperty -Value 'inbound'

    $table = [PSCustomObject]@{}
    $table | Add-Member -Name 'result.state' -MemberType Noteproperty -Value $lastResult.State
    $table | Add-Member -Name 'result.code' -MemberType Noteproperty -Value $lastResult.Code
    $table | Add-Member -Name 'result.phrase' -MemberType Noteproperty -Value $lastResult.Phrase

    $teamsOut = CreateTable 'teamsOut' $lastResult.teamsOut
    $teamsIn = CreateTable 'teamsIn' $lastResult.teamsIn

    switch ($PSCmdlet.ParameterSetName)
    {
        "Escalation"{
            $lastResult.teamsInEscalation | Add-Member -Name 'flow' -MemberType Noteproperty -Value 'inbound'
            $escalation = CreateTable 'teamsInEscalation' $lastResult.teamsInEscalation
        }
        "Transfer"{
            $lastResult.teamsInTransferTarget | Add-Member -Name 'flow' -MemberType NoteProperty -Value 'inbound'
            $transfer = CreateTable 'teamsInTransferTarget' $lastResult.teamsInTransferTarget
        }
        "Simulring"{
            $lastResult.teamsInSimulring | Add-Member -Name 'flow' -MemberType NoteProperty -Value 'inbound'
            $simulring = CreateTable 'teamsInSimulring' $lastResult.teamsInSimulring
        }
    }

    if (!$HideTable) {
        Write-Host ( "`r`n`r`nTest: {0}`r`n" -f $testTitles[$PSCmdlet.ParameterSetName] )
        WriteTable $table
        WriteTable $teamsOut
        WriteTable $teamsIn
        WriteTable $escalation
        WriteTable $transfer
        WriteTable $simulring
    }

    if ($lastResult.state -eq 'failed') {
        Write-Error "Failed test: $($lastResult.batchId)"
    }

    return ($lastResult.state -ne 'failed')
}

return $False