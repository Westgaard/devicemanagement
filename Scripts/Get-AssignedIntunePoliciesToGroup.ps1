# Script to find and display assigned Intune policies and apps for a specific user or device
# Original script from https://timmyit.com/2019/12/04/get-all-assigned-intune-policies-and-apps-per-azure-ad-group/
# Modified by Jon Arne Westgaard

#Connect and change schema
Connect-AzureAD
Connect-MSGraph
Update-MSGraphEnvironment -SchemaVersion beta
Connect-MSGraph

# Function to get "all" Intune-configuration
Function Get-IntuneConfig {

    # Get all config
    # Apps
    $AllAssignedApps = Get-IntuneMobileApp -Filter "isAssigned eq true" -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments

    # App Protection Policy Android
    $AppProtectionPolicyConfigAndroid = Get-IntuneAppProtectionPolicyAndroid -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments

    # App Protection Policy iOS
    $AppProtectionPolicyConfigiOS = Get-IntuneAppProtectionPolicyiOS -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments 
    
    # Device Compliance
    $AllDeviceCompliance = Get-IntuneDeviceCompliancePolicy -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments
 
    # Device Configuration
    $AllDeviceConfig = Get-IntuneDeviceConfigurationPolicy -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments 
 
    # Device Configuration Powershell Scripts 
    $Resource = "deviceManagement/deviceManagementScripts"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=groupAssignments"
    $DMS = Invoke-MSGraphRequest -HttpMethod GET -Url $uri
  
    # Administrative templates
    $Resource = "deviceManagement/groupPolicyConfigurations"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=Assignments"
    $ADMT = Invoke-MSGraphRequest -HttpMethod GET -Url $uri

    # Settings Catalog
    $Resource = "deviceManagement/configurationPolicies"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=Assignments"
    $SC = Invoke-MSGraphRequest -HttpMethod GET -Url $uri
}

#Function to print all Intune-configuration assigned to the group(s) and/or device you specify
Function Print-IntuneConfig {
  
  Param(
      $User,
      $Device,
      $UserGroup
  )

$Configuration = @(
    [pscustomobject]@{Type='';ConfigName='';AssignedTo='';AssignmentType=''}
)

If (!($user -or $device -or $UserGroup)) {
    throw "Please specify User, Device or UserGroup"
}

If ($User) { 
    $groups = Get-AzureADUserMembership -ObjectId $user | select DisplayName, ObjectID
}
if ($device) {

    $AzureADDevice = Get-AzureADDevice -SearchString $device
    If (!($AzureADDevice)) { throw "Could not find $device"}
    $DeviceGroups = (Invoke-MSGraphRequest -HttpMethod GET -Url "https://graph.microsoft.com/v1.0/devices/$($AzureADDevice.ObjectID)/memberOf").value.DisplayName
    $Groups = @()
    Foreach ($DevGroup in $DeviceGroups) {
        $Groups += Get-AADGroup -Filter "displayname eq '$DevGroup'" | select Displayname, ID
    }

}

If ($UserGroup) {
    $Groups = Get-AADGroup -filter "displayname eq '$usergroup'" | select Displayname, ID
    
}

ForEach ($MedlemGroup in $Groups) { 
        If ($MedlemGroup.ObjectID) {
            $Group = Get-AADGroup -groupId $MedlemGroup.ObjectID
        }
        Elseif ($MedlemGroup.ID) {
               $Group = Get-AADGroup -groupId $MedlemGroup.ID
        }
        If (!($Group)) { throw "Could not find $group"}
        Write-host "AAD Group Name: $($Group.displayName)" -ForegroundColor Green


        # Apps
        $MedlemGroupApps = $AllAssignedApps | Where-Object {$_.assignments -match $Group.id}
        If ($MedlemGroupApps.DisplayName.Count -gt 0) { 
        Write-host "  Number of Apps found: $($MedlemGroupApps.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $MedlemGroupApps) {            
                $data = [pscustomobject]@{Type='App';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType="Included"}
                $Configuration += $data
                Write-host "    " $Config.displayName -ForegroundColor Yellow
            }
        }

        # App Protection Policy Android
        $AssAppProtectionAndroid = $AppProtectionPolicyConfigAndroid | Where-Object {$_.assignments -match $Group.id}
        If ($AssAppProtectionAndroid.DisplayName.Count -gt 0) {Write-host "  Number of App Protection Policy Android found: $($AssAppProtectionAndroid.DisplayName.Count)" -ForegroundColor cyan
        Foreach ($Config in $AssAppProtectionAndroid) {
            $data = [pscustomobject]@{Type='AppProtectionPolicy';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType="Included"}
            $Configuration += $data
            Write-host "    " $Config.displayName -ForegroundColor Yellow
            }
        }

        # App Protection Policy iOS
        $AssignedAppProtectioniOS = $AppProtectionPolicyConfigiOS | Where-Object {$_.assignments -match $Group.id}
        If ($AssignedAppProtectioniOS.DisplayName.Count -gt 0) {Write-host "  Number of App Protection Policy iOS found: $($AssignedAppProtectioniOS.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $AssignedAppProtectioniOS) {
            $data = [pscustomobject]@{Type='AppProtectionPolicyConfigIOS';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType="Included"}
            $Configuration += $data
            Write-host "    " $Config.displayName -ForegroundColor Yellow
 
            }
        }

            # Device Compliance
        $AssignedDevCompliance = $AllDeviceCompliance | Where-Object {$_.assignments -match $Group.id}
        If ($AssignedDevCompliance.DisplayName.Count -gt 0) { Write-host "  Number of Device Compliance policies found: $($AssignedDevCompliance.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $AssignedDevCompliance) {
            $data = [pscustomobject]@{Type='DeviceCompliance';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType="Included"}
            $Configuration += $data
            Write-host "    " $Config.displayName -ForegroundColor Yellow
 
            }
        }
 
        # Device Configuration
        $AssignedDevConfig = $AllDeviceConfig  | Where-Object {$_.assignments -match $Group.id}
        If ($AssignedDevConfig.DisplayName.Count -gt 0) { Write-host "  Number of Device Configurations found: $($AssignedDevConfig.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $AssignedDevConfig) {
            $data = [pscustomobject]@{Type='DeviceConfigurationPolicy';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType="Included"}
            $Configuration += $data
            Write-host "    " $Config.displayName -ForegroundColor Yellow
 
            }
        }
 
        # Device Configuration Powershell Scripts 
        $AllDeviceConfigScripts = $DMS.value | Where-Object {$_.groupAssignments -match $Group.id}
        If ($AllDeviceConfigScripts.DisplayName.Count -gt 0) {Write-host "  Number of Device Configurations Powershell Scripts found: $($AllDeviceConfigScripts.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $AllDeviceConfigScripts) {
            $data = [pscustomobject]@{Type='PowershellScripts';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType="Included"}
            $Configuration += $data
                Write-host "    " $Config.displayName -ForegroundColor Yellow
 
            }
        }
 
        # Administrative templates
        $AllADMT = $ADMT.value | Where-Object {$_.assignments -match $Group.id}
        If ($AllADMT.DisplayName.Count -gt 0) {Write-host "  Number of Device Administrative Templates found: $($AllADMT.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $AllADMT) {
                Foreach ($Assignment in $config.assignments.target ) {
                    If ($Assignment.GroupID -eq $group.id) {
                                        
                        If ($assignment.'@odata.type' -eq '#microsoft.graph.exclusionGroupAssignmentTarget') {
                            $data = [pscustomobject]@{Type='App';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType="Excluded"}
                            Write-host "    Excluded: " $Config.displayName -ForegroundColor Red                
                        }
                        Else {
                            $data = [pscustomobject]@{Type='App';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType="Included"}
                            Write-host "    " $Config.displayName -ForegroundColor Yellow}
                        $Configuration += $data
                    }
                }
            }
        }

        # Settings Catalog
        $AllSC = $SC.value | Where-Object {$_.assignments -match $Group.id}
        If ($AllSC.name.Count -gt 0) { Write-host "  Number of Device Settings Catalogs found: $($AllSC.Name.Count)" -ForegroundColor cyan

            Foreach ($Config in $AllSC) {
                $data = [pscustomobject]@{Type='DeviceCompliance';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType="Included"}
                $Configuration += $data
                Write-host "    ", $Config.Name -ForegroundColor Yellow
            }
        }
    }
}

# To get all config, does not have to be run every time:
Get-IntuneConfig
Print-IntuneConfig -UserGroup "MyUserGroup"
Print-IntuneConfig -Device "MyDevice"
Print-IntuneConfig -User "myusername@mycompany.com"
