# devicemanagement

Useful scripts and commands for devicemanagement and application packaging.

## Applications:
### Find uninstall-strings for all applications:
```
Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Select-Object -Property DisplayName, UninstallString
```

### Find uninstall-string for a specific application: (Note the backslash to allow searching for +)
```
Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Select-Object -Property DisplayName, UninstallString | Where-Object {$_.DisplayName -match 'Notepad\+\+' }
```

### Compare installed application versions, useful for requirement-scrips when updating apps
```
$VMware = Get-Package "VMware Horizon Client" -ProviderName MSI -ErrorAction SilentlyContinue
[Version]$Vmware.Version -lt [version]"8.8.1.34412"
```

## Powershell App Deploy Toolkit
### Set logpath for PS ADT to Intune log-folder
Working with Intune and applications, having access to all logfiles are crucial to finding and resolving errors. If you change the default log-path in PS ADT to the IntuneManagementExtension-folder, these logfiles will be collected when you select "Collect diagnostics" in Intune.

Simply change Toolkit_LogPath to the following in .\AppDeployToolkit\AppDeployToolkitConfig.xml: ````<Toolkit_LogPath>$env:Programdata\Microsoft\IntuneManagementExtension\Logs</Toolkit_LogPath>````

### Install command to show gui during installation
```powershell.exe -ExecutionPolicy Bypass -File .\InstallWin32.ps1 -DeploymentType Install```

Place [InstallWin32.ps1](https://github.com/Westgaard/devicemanagement/blob/main/Scripts/InstallWin32.ps1) in same folder as Deploy-Application.ps1

## Powershell
### Restart Powershell in 64-bit (Runs as default in 32-bit from Intune)
```## Starter PowerShell i 64-bit modus dersom sesjonen er startet i 32-bit
    if (!([Environment]::Is64BitProcess )) {
        if ($MyInvocation.Line) {
& "$env:windir\SysNative\WindowsPowerShell\v1.0\Powershell.exe" -ExecutionPolicy Bypass -NoLogo -NoProfile $MyInvocation.Line
        } Else {
& "$env:windir\SysNative\WindowsPowerShell\v1.0\Powershell.exe" -ExecutionPolicy Bypass -NoLogo -NoProfile -File ($MyInvocation.InvocationName)
            }
        EXIT $LASTEXITCODE
    }
```

### Add device list to AAD group (For example when exporting exposed devices from Security Center)
```
Connect-MSGraph
Update-MSGraphEnvironment -SchemaVersion "Beta" -Quiet
Connect-MSGraph -Quiet

# The group idwe are adding devices to
$groupId = "12121212-34234234-45345-345345-34565756"

$devices = Import-Csv -Path "C:\DevicesExport.csv"

foreach ($device in $devices) {
    $deviceName = $device.DeviceName
    $deviceId = (Get-MgDevice -Filter "displayName eq '$deviceName'").Id

    # Add the device to group
    Add-AzureADGroupMember -ObjectId $groupId -RefObjectId $deviceId
    Write-host "Adding $deviceid"
}
```

## Security Center / Microsoft 365 Defendeder
### Advanced hunting query to get all users with installed software
```
let klient = DeviceTvmSoftwareVulnerabilities
| where SoftwareName contains "YourApplication"
| distinct DeviceName;
DeviceLogonEvents
| where DeviceName in (klient) and AccountName contains "@yourdomain"
| distinct AccountName
```
