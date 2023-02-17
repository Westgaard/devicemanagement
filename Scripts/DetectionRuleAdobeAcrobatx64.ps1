$AppName = "Adobe Acrobat (64-bit)"
$AppRegKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
$AppRegName = Get-ChildItem $AppRegKey | ForEach-Object {Get-ItemProperty $_.PSPath} | Where-Object {$_.DisplayName -like $AppName}

if ($AppRegName -ne $null) {
    Write-Output "Adobe Acrobat is installed"
    exit 0
}
else {
    Write-Output "Adobe Acrobat is not installed"
    exit 1
}
