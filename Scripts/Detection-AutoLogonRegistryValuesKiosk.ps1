$AutoAdminLogon = (Get-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -ErrorAction SilentlyContinue).AutoAdminLogon
$AutoLogonSID = (Get-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AUtoLogonSID" -ErrorAction SilentlyContinue).AutoLogonSID
$DefaultUserName = (Get-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -ErrorAction SilentlyContinue).DefaultUsername
$IsConnectedAutoLogon = (Get-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "IsConnectedAutoLogon" -ErrorAction SilentlyContinue).IsConnectedAutoLogon

If (!($AutoAdminLogon -and $DefaultUserName -and $IsConnectedAutoLogon -and $AutoLogonSID)) {
    Write-Host "Registry-verdier satt feil! AutoAdminlogon: $autoadminlogon, DefaultUsername: $DefaultUserName, IsConnectedAutoLogon: $IsConnectedAutoLogon, AutoLogonSID: $AutoLogonSID"
    Exit 1
}

Else {
    Write-Host "OK! AutoAdminlogon: $autoadminlogon, DefaultUsername: $DefaultUserName, IsConnectedAutoLogon: $IsConnectedAutoLogon, AutoLogonSID: $AutoLogonSID"
    Exit 0
    }
