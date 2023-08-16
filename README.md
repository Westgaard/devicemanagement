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
