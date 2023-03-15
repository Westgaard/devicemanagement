Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Type String -Value 1 -ErrorAction SilentlyContinue
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Type String -Value "KioskUser0" -ErrorAction SilentlyContinue
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "IsConnectedAutoLogon" -Type Dword -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoLogonSID" -Value (Get-LocalUser -Name kioskuser0 | select SID).SID.Value -Force

$AutoAdminLogon = (Get-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -ErrorAction SilentlyContinue).AutoAdminLogon
$AutoLogonSID = (Get-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AUtoLogonSID" -ErrorAction SilentlyContinue).AutoLogonSID
$DefaultUserName = (Get-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -ErrorAction SilentlyContinue).DefaultUsername
$IsConnectedAutoLogon = (Get-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "IsConnectedAutoLogon" -ErrorAction SilentlyContinue).IsConnectedAutoLogon

Write-Host "Registry-verdier satt! AutoAdminlogon: $autoadminlogon, DefaultUsername: $DefaultUserName, IsConnectedAutoLogon: $IsConnectedAutoLogon, AutoLogonSID: $AutoLogonSID"
