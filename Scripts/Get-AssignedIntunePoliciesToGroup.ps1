# Script to find and display assigned Intune policies and apps for a specific user or device
# Original script from https://timmyit.com/2019/12/04/get-all-assigned-intune-policies-and-apps-per-azure-ad-group/
# Modified by Jon Arne Westgaard

#Connect and change schema
Connect-MSGraph
Update-MSGraphEnvironment -SchemaVersion beta
Connect-MSGraph

# Which AAD group do we want to check against
$UserGroups = Get-AzureADUserMembership -ObjectId "user@domain.com" | select -ExpandProperty DisplayName
$device = Get-AzureADDevice -SearchString "client1"
$DeviceGroups = (Invoke-MSGraphRequest -HttpMethod GET -Url "https://graph.microsoft.com/v1.0/devices/$($device.ObjectID)/memberOf").value.DisplayName

# To find configuration assigned to device
#$groups = $devicegroups

# To find configuration assigned to user
#$groups = $Usergroups

# To find configuration assigned to specific group
$groups = "YourGroupName"

#$Configuration = @()
#### Config Don't change
ForEach ($MedlemGroup in $Groups)
{ 
    $Group = Get-AADGroup -Filter "displayname eq '$MedlemGroup'"
    Write-host "AAD Group Name: $($Group.displayName)" -ForegroundColor Green

    # Apps
    $AllAssignedApps = Get-IntuneMobileApp -Filter "isAssigned eq true" -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments | Where-Object {$_.assignments -match $Group.id}
    If ($AllAssignedApps.DisplayName.Count -gt 0) { Write-host "  Number of Apps found: $($AllAssignedApps.DisplayName.Count)" -ForegroundColor cyan
        Foreach ($Config in $AllAssignedApps) {
 
            Write-host "    " $Config.displayName -ForegroundColor Yellow
        }
    }

    # App Protection Policy Android
    $AppProtectionPolicyConfigAndroid = Get-IntuneAppProtectionPolicyAndroid -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments | Where-Object {$_.assignments -match $Group.id}
    If ($AppProtectionPolicyConfigAndroid.DisplayName.Count -gt 0) {Write-host "  Number of App Protection Policy Android found: $($AppProtectionPolicyConfigAndroid.DisplayName.Count)" -ForegroundColor cyan
    Foreach ($Config in $AppProtectionPolicyConfigAndroid) {
 
        Write-host "    " $Config.displayName -ForegroundColor Yellow
        $Config.displayName += $Config.displayName
        }
    }

    # App Protection Policy iOS
    $AppProtectionPolicyConfigiOS = Get-IntuneAppProtectionPolicyiOS -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments | Where-Object {$_.assignments -match $Group.id}
    If ($AppProtectionPolicyConfigiOS.DisplayName.Count -gt 0) {Write-host "  Number of App Protection Policy iOS found: $($AppProtectionPolicyConfigiOS.DisplayName.Count)" -ForegroundColor cyan
        Foreach ($Config in $AppProtectionPolicyConfigiOS) {
 
        Write-host "    " $Config.displayName -ForegroundColor Yellow
 
        }
    }

    # Device Compliance
    $AllDeviceCompliance = Get-IntuneDeviceCompliancePolicy -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments | Where-Object {$_.assignments -match $Group.id}
    If ($AllDeviceCompliance.DisplayName.Count -gt 0) { Write-host "  Number of Device Compliance policies found: $($AllDeviceCompliance.DisplayName.Count)" -ForegroundColor cyan
        Foreach ($Config in $AllDeviceCompliance) {
 
        Write-host "    " $Config.displayName -ForegroundColor Yellow
 
        }
    }
 
    # Device Configuration
    $AllDeviceConfig = Get-IntuneDeviceConfigurationPolicy -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments | Where-Object {$_.assignments -match $Group.id}
    If ($AllDeviceConfig.DisplayName.Count -gt 0) { Write-host "  Number of Device Configurations found: $($AllDeviceConfig.DisplayName.Count)" -ForegroundColor cyan
        Foreach ($Config in $AllDeviceConfig) {
 
        Write-host "    " $Config.displayName -ForegroundColor Yellow
 
        }
    }
 
    # Device Configuration Powershell Scripts 
    $Resource = "deviceManagement/deviceManagementScripts"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=groupAssignments"
    $DMS = Invoke-MSGraphRequest -HttpMethod GET -Url $uri
    $AllDeviceConfigScripts = $DMS.value | Where-Object {$_.groupAssignments -match $Group.id}
    If ($AllDeviceConfigScripts.DisplayName.Count -gt 0) {Write-host "  Number of Device Configurations Powershell Scripts found: $($AllDeviceConfigScripts.DisplayName.Count)" -ForegroundColor cyan
 
        Foreach ($Config in $AllDeviceConfigScripts) {
 
            Write-host "    " $Config.displayName -ForegroundColor Yellow
 
        }
    }
 
 
    # Administrative templates
    $Resource = "deviceManagement/groupPolicyConfigurations"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=Assignments"
    $ADMT = Invoke-MSGraphRequest -HttpMethod GET -Url $uri
    $AllADMT = $ADMT.value | Where-Object {$_.assignments -match $Group.id}
    If ($AllADMT.DisplayName.Count -gt 0) {Write-host "  Number of Device Administrative Templates found: $($AllADMT.DisplayName.Count)" -ForegroundColor cyan
        Foreach ($Config in $AllADMT) {
            Foreach ($Assignment in $config.assignments.target ) {
                If ($Assignment.GroupID -eq $group.id) {
                    If ($assignment.'@odata.type' -eq '#microsoft.graph.exclusionGroupAssignmentTarget') {
                        Write-host "    Excluded: " $Config.displayName -ForegroundColor Red                
                    }
                    Else {Write-host "    " $Config.displayName -ForegroundColor Yellow}
                }
            }
        }
    }

    # Settings Catalog
    $Resource = "deviceManagement/configurationPolicies"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=Assignments"
    $SC = Invoke-MSGraphRequest -HttpMethod GET -Url $uri
    $AllSC = $SC.value | Where-Object {$_.assignments -match $Group.id}
    If ($SC.DisplayName.Count -gt 0) { Write-host "  Number of Device Settings Catalogs found: $($AllSC.DisplayName.Count)" -ForegroundColor cyan

        Foreach ($Config in $AllSC) {

            Write-host "    ", $Config.Name -ForegroundColor Yellow

        }
    }
}

