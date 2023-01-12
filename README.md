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
