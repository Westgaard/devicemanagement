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
    $global:AllAssignedApps = Get-IntuneMobileApp -Filter "isAssigned eq true" -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments

    # App Protection Policy Android
    $global:AppProtectionPolicyConfigAndroid = Get-IntuneAppProtectionPolicyAndroid -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments

    # App Protection Policy iOS
    $global:AppProtectionPolicyConfigiOS = Get-IntuneAppProtectionPolicyiOS -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments 
    
    # Device Compliance
    $global:AllDeviceCompliance = Get-IntuneDeviceCompliancePolicy -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments
 
    # Device Configuration
    $global:AllDeviceConfig = Get-IntuneDeviceConfigurationPolicy -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments 
 
    # Device Configuration Powershell Scripts 
    $Resource = "deviceManagement/deviceManagementScripts"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=groupAssignments"
    $global:DMS = Invoke-MSGraphRequest -HttpMethod GET -Url $uri
  
    # Administrative templates
    $Resource = "deviceManagement/groupPolicyConfigurations"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=Assignments"
    $global:ADMT = Invoke-MSGraphRequest -HttpMethod GET -Url $uri

    # Settings Catalog
    $Resource = "deviceManagement/configurationPolicies"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=Assignments"
    $global:SC = Invoke-MSGraphRequest -HttpMethod GET -Url $uri

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
    
    $AllUsersGroup = @()
    $AllUsersGroup += New-Object -TypeName psobject -Property @{DisplayName="All Users"; ObjectID="acacacac-9df4-4c7d-9d50-4ef0226f57a9"}
    
    $groups += $AllUsersGroup
}
if ($device) {

    $AzureADDevice = Get-AzureADDevice -SearchString $device
    If (!($AzureADDevice)) { throw "Could not find $device"}
    $DeviceGroups = (Invoke-MSGraphRequest -HttpMethod GET -Url "https://graph.microsoft.com/v1.0/devices/$($AzureADDevice.ObjectID)/memberOf").value.DisplayName
    $Groups = @()
    Foreach ($DevGroup in $DeviceGroups) {
        $Groups += Get-AADGroup -Filter "displayname eq '$DevGroup'" | select Displayname, ID
    }
    $AllDevicesGroup= @()
    $AllDevicesGroup += New-Object -TypeName psobject -Property @{DisplayName="All Devices"; ObjectID="adadadad-808e-44e2-905a-0b7873a8a531"}

    $groups += $AllDevicesGroup
}

If ($UserGroup) {
    $Groups = Get-AADGroup -filter "displayname eq '$usergroup'" | select Displayname, ID
    
}

ForEach ($MedlemGroup in $Groups) { 
        If ($MedlemGroup.Displayname -eq "All Users") {
            $group = $MedlemGroup
        }
        ElseIf ($MedlemGroup.Displayname -eq "All Devices") {
            $group = $MedlemGroup
        }
        ElseIf ($MedlemGroup.ObjectID) {
            $Group = Get-AADGroup -groupId $MedlemGroup.ObjectID
        }
        ElseIf ($MedlemGroup.ID) {
            $Group = Get-AADGroup -groupId $MedlemGroup.ID
        }

        If (!($Group)) { throw "Could not find $group"}
        Write-host "AAD Group Name: $($Group.displayName)" -ForegroundColor Green


        # Apps
        $MedlemGroupApps = $AllAssignedApps | Where-Object {$_.assignments -match $Group.id}
        If ($MedlemGroupApps.DisplayName.Count -gt 0) { 
        Write-host "  Number of Apps found: $($MedlemGroupApps.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $MedlemGroupApps) {
                Foreach ($assignments in $config.assignments) {
                    If ($assignments.target.groupId -eq $group.id) {
                        $appType = $config.'@odata.type'.Replace("#microsoft.graph.","")
                        $data = [pscustomobject]@{Type=$AppType;ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType=$Assignments.Intent}
                        $Configuration += $data
                        If ($Assignments.target.groupId)  {
                            $GroupDisplayName = Get-AzureADGroup -ObjectId $Assignments.target.groupId | select -ExpandProperty Displayname
                        }
                        Write-host "    " $config.displayName -ForegroundColor Yellow -NoNewline; Write-Host " "$($Assignments.Intent) -ForegroundColor Magenta -NoNewline ;  Write-Host " "$GroupDisplayName -NoNewline -ForegroundColor Green; Write-Host " "$AppType
                    }
                }
            }
        }

        # App Protection Policy Android
        $AssAppProtectionAndroid = $AppProtectionPolicyConfigAndroid | Where-Object {$_.assignments -match $Group.id}
        If ($AssAppProtectionAndroid.DisplayName.Count -gt 0) {
            Write-host "  Number of App Protection Policy Android found: $($AssAppProtectionAndroid.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $AssAppProtectionAndroid) {
                Foreach ($assignments in $config.assignments) {
                    If ($assignments.target.groupId -eq $group.id) {
                        $data = [pscustomobject]@{Type='AppProtectionPolicy';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType=$config.Intent}
                        $Configuration += $data
                        Write-host "    " $config.displayName -ForegroundColor Yellow -NoNewline; Write-Host " "$GroupDisplayName -ForegroundColor Green
                    }
                }
            }
        }

        # App Protection Policy iOS
        $AssignedAppProtectioniOS = $AppProtectionPolicyConfigiOS | Where-Object {$_.assignments -match $Group.id}
        If ($AssignedAppProtectioniOS.DisplayName.Count -gt 0) {Write-host "  Number of App Protection Policy iOS found: $($AssignedAppProtectioniOS.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $AssignedAppProtectioniOS) {
                $data = [pscustomobject]@{Type='AppProtectionPolicyConfigIOS';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType="Included"}
                $Configuration += $data
                Write-host "    " $Config.displayName -ForegroundColor Yellow -NoNewline; Write-Host " "$GroupDisplayName -ForegroundColor Green
            }
        }

        # Device Compliance
        $AssignedDevCompliance = $AllDeviceCompliance | Where-Object {$_.assignments -match $Group.id}
        If ($AssignedDevCompliance.DisplayName.Count -gt 0) {
        Write-host "  Number of Device Compliance policies found: $($AssignedDevCompliance.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $AssignedDevCompliance) {
                ForEach ($assignments in $config.assignments) {
                    If ($assignments.target.groupId -eq $group.id) {
                        $data = [pscustomobject]@{Type='DeviceCompliance';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)"}
                        $Configuration += $data
                        Write-host "    " $config.displayName -ForegroundColor Yellow -NoNewline; Write-Host " "$GroupDisplayName -ForegroundColor Green
                    }
                }
            }
        }
 
        # Device Configuration
        $AssignedDevConfig = $AllDeviceConfig  | Where-Object {$_.assignments -match $Group.id}
        If ($AssignedDevConfig.DisplayName.Count -gt 0) {
            Write-host "  Number of Device Configurations found: $($AssignedDevConfig.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $AssignedDevConfig) {
                Foreach ($assignments in $config.assignments) {
                    If ($assignments.target.groupId -eq $group.id) {
                        If ($assignments.target.'@odata.type' -match "#microsoft.graph.exclusionGroupAssignmentTarget") { $AssMode = "Excluded"} Else {$AssMode = "Included"}
                        $data = [pscustomobject]@{Type='DeviceConfigurationPolicy';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType=$assmode}
                        $Configuration += $data
                        Write-host "    " $config.displayName -ForegroundColor Yellow -NoNewline; Write-Host " "$AssMode -ForegroundColor Magenta -NoNewline ;  Write-Host " "$GroupDisplayName -ForegroundColor Green
                    }
                }
            }
        }
 
        # Device Configuration Powershell Scripts 
        $AllDeviceConfigScripts = $DMS.value | Where-Object {$_.groupAssignments -match $Group.id}
        If ($AllDeviceConfigScripts.DisplayName.Count -gt 0) {
            Write-host "  Number of Device Configurations Powershell Scripts found: $($AllDeviceConfigScripts.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $AllDeviceConfigScripts) {
                $data = [pscustomobject]@{Type='PowershellScripts';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType="Included"}
                $Configuration += $data
                Write-host "    " $Config.displayName -ForegroundColor Yellow -NoNewline; Write-Host " "$GroupDisplayName -ForegroundColor Green
            }
        }
 
        # Administrative templates
        $AllADMT = $ADMT.value | Where-Object {$_.assignments -match $Group.id}
        If ($AllADMT.DisplayName.Count -gt 0) {Write-host "  Number of Device Administrative Templates found: $($AllADMT.DisplayName.Count)" -ForegroundColor cyan
            Foreach ($Config in $AllADMT) {
                Foreach ($Assignment in $config.assignments.target ) {
                    If ($Assignment.GroupID -eq $group.id) {
                        If ($assignment.target.'@odata.type' -match "#microsoft.graph.exclusionGroupAssignmentTarget") { $AssMode = "Excluded"} Else {$AssMode = "Included"}
                        $data = [pscustomobject]@{Type='ADMT';ConfigName="$($Config.displayName)";AssignedTo="$($Group.displayName)";AssignmentType=$AssMode}
                        $Configuration += $data
                        Write-host "    " $config.displayName -ForegroundColor Yellow -NoNewline; Write-Host " "$AssMode -ForegroundColor Magenta -NoNewline ;  Write-Host " "$GroupDisplayName -ForegroundColor Green
                    }
                }
            }
        }

        # Settings Catalog
        $AllSC = $SC.value | Where-Object {$_.assignments -match $Group.id}
        If ($AllSC.name.Count -gt 0) {
            Write-host "  Number of Device Settings Catalogs found: $($AllSC.Name.Count)" -ForegroundColor cyan
            Foreach ($Config in $AllSC) {
                Foreach ($Assignment in $config.assignments) {
                    If ($assignment.target.groupId -eq $group.id) {
                        If ($assignment.target.'@odata.type' -match "#microsoft.graph.exclusionGroupAssignmentTarget") { $AssMode = "Excluded"} Else {$AssMode = "Included"}
                        $data = [pscustomobject]@{Type='DeviceCompliance';ConfigName="$($Config.Name)";AssignedTo="$($Group.displayName)";AssignmentType="Included"}
                        $Configuration += $data
                        Write-host "    " $config.Name -ForegroundColor Yellow -NoNewline; Write-Host " "$AssMode -ForegroundColor Magenta -NoNewline ;  Write-Host " "$GroupDisplayName -ForegroundColor Green
                    }
                }
            }
        }
    }
}
$configuration
# To get all config, does not have to be run every time:
Get-IntuneConfig
Print-IntuneConfig -UserGroup "MyUserGroup"
#Print-IntuneConfig -Device "MyDevice"
#Print-IntuneConfig -User "myusername@mycompany.com"
