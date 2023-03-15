$AutoAdminLogon = (Get-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -ErrorAction SilentlyContinue).AutoAdminLogon
$AutoLogonSID = (Get-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AUtoLogonSID" -ErrorAction SilentlyContinue).AutoLogonSID
$DefaultUserName = (Get-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -ErrorAction SilentlyContinue).DefaultUsername
$IsConnectedAutoLogon = (Get-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "IsConnectedAutoLogon" -ErrorAction SilentlyContinue).IsConnectedAutoLogon

If (($AutoAdminLogon -ne 1) -or ($null -eq $AutoLogonSID) -or ($DefaultUserName -ne "KioskUser0") -or ($IsConnectedAutoLogon -ne 0)) {
    Write-Host "Registry-verdier satt feil! AutoAdminlogon: $autoadminlogon, DefaultUsername: $DefaultUserName, IsConnectedAutoLogon: $IsConnectedAutoLogon, AutoLogonSID: $AutoLogonSID"
    Exit 1
}

Else {
    Write-Host "AutoAdminlogon: $autoadminlogon, DefaultUsername: $DefaultUserName, IsConnectedAutoLogon: $IsConnectedAutoLogon, AutoLogonSID: $AutoLogonSID"
    Exit 0
    }
