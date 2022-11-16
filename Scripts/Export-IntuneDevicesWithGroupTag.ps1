Connect-MSGraph
Update-MSGraphEnvironment -SchemaVersion "Beta" -Quiet
Connect-MSGraph -Quiet
Connect-AzureAD

# Get all autopilot devices with group tag
$AutopilotDevicesWithGropTag = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/windowsAutopilotDeviceIdentities" | Get-MSGraphAllPages | where groupTag -eq "MyCoolGroupTag"
$DeviceList = @(
    [pscustomobject]@{id='';userId='';deviceName ='';ownerType='';managedDeviceOwnerType='';managementState='';enrolledDateTime ='';lastSyncDateTime='';chassisType ='';operatingSystem  ='';deviceType='';AssignmentType='';complianceState='';jailBroken='';managementAgent='';osVersion='';easActivated='';easDeviceId='';easActivationDateTime='';aadRegistered='';azureADRegistered='';deviceEnrollmentType='';lostModeState='';activationLockBypassCode='';emailAddress='';azureActiveDirectoryDeviceId='';azureADDeviceId='';deviceRegistrationState='';deviceCategoryDisplayName='';isSupervised='';exchangeLastSuccessfulSyncDateTime='';exchangeAccessState='';exchangeAccessStateReason=''}
)
$NotActive =  @()
ForEach ($ApDevice in $AutopilotDevicesWithGropTag) {
    $Device = Get-IntuneManagedDevice -managedDeviceId $ApDevice.managedDeviceId
    If ($?) {
        $Device.userid
        $Data  = [pscustomobject]@{id="$($Device.id)";userId="$($Device.userid)";deviceName ="$($Device.devicename)";ownerType="$($Device.Ownertype)";managedDeviceOwnerType="$($Device.managedDeviceOwnerType)";managementState="$($Device.managementState)";enrolledDateTime ="$($Device.enrolledDateTime)";lastSyncDateTime="$($Device.lastSyncDateTime)";chassisType ="$($Device.chassisType)";operatingSystem="$($Device.operatingSystem)";deviceType="$($Device.deviceType)";AssignmentType="$($Device.AssignmentType)";complianceState="$($Device.complianceState)";jailBroken="$($Device.jailBroken)";managementAgent="$($Device.managementAgent)";osVersion="$($Device.osVersion)";easActivated="$($Device.easActivated)";easDeviceId="$($Device.easDeviceId)";easActivationDateTime="$($Device.easActivationDateTime)";aadRegistered="$($Device.aadRegistered)";azureADRegistered="$($Device.azureADRegistered)";deviceEnrollmentType="$($Device.deviceEnrollmentType)";lostModeState="$($Device.lostModeState)";activationLockBypassCode="$($Device.activationLockBypassCode)";emailAddress="$($Device.emailAddress)";azureActiveDirectoryDeviceId="$($Device.azureActiveDirectoryDeviceId)";azureADDeviceId="$($Device.azureADDeviceId)";deviceRegistrationState="$($Device.deviceRegistrationState)";deviceCategoryDisplayName="$($Device.deviceCategoryDisplayName)";isSupervised="$($Device.isSupervised)";exchangeLastSuccessfulSyncDateTime="$($Device.exchangeLastSuccessfulSyncDateTime)";exchangeAccessState="$($Device.exchangeAccessState)";exchangeAccessStateReason="$($Device.exchangeAccessStateReason)"}
        $DeviceList += $Data
    }
    else { $NotActive += $($ApDevice.serialNumber) }
}
[PSCustomObject]$DeviceList | Export-Csv -Delimiter "," -Path MyIntuneDevicesWithCoolGroupTag.csv
