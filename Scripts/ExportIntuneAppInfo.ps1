# Get all Intune-apps with type, name, assignedgroup and assignment type
# 2023 Jon Arne Westgaard

Connect-MSGraph
$Csvfile = "IntuneApps.csv"

# Get all Apps
$AllAssignedApps = Get-IntuneMobileApp -Filter "isAssigned eq true" -Select id, displayName, assignments -Expand assignments

Write-host "  Number of Apps found: $($AllAssigned.DisplayName.Count)" -ForegroundColor cyan
$AppInfo = @(
    [pscustomobject]@{AppType='';AppName='';AssignedTo='';AssignmentType='';AssignmentMode=''}
)

Foreach ($App in $AllAssignedApps) {
    Foreach ($assignments in $app.assignments) {
        
        If ($Assignments.target.groupId)  {
            $GroupDisplayName = Get-AzureADGroup -ObjectId $Assignments.target.groupId | select -ExpandProperty Displayname
        }
        Elseif ($app.assignments.id -match "acacacac-9df4-4c7d-9d50-4ef0226f57a9") {
            $GroupDisplayName = "All users"
        }
        Elseif ($app.assignments.id -match "adadadad-808e-44e2-905a-0b7873a8a531") {
            $GroupDisplayName = "All devices"
            }
        If ($assignments.target.'@odata.type' -match "#microsoft.graph.exclusionGroupAssignmentTarget") { $AssMode = "Excluded"} Else {$AssMode = "Included"}
        $appType = $app.'@odata.type'.Replace("#microsoft.graph.","")
        $data = [pscustomobject]@{AppType=$AppType;AppName="$($app.displayName)";AssignedTo=$GroupDisplayName;AssignmentType=$Assignments.Intent;AssignmentMode=$AssMode}
        $AppInfo += $data
        Write-host "    " $app.displayName -ForegroundColor Yellow -NoNewline; Write-Host " "$($Assignments.Intent) -ForegroundColor Magenta -NoNewline ;  Write-Host " " $AssMode -nonewline; Write-Host " "$GroupDisplayName -NoNewline -ForegroundColor Green; Write-Host " "$AppType
    }               
}

$ExportArray = @()
$AppInfo | ForEach-Object {
    $ExportArray += [pscustomobject]@{
        AppType = $_.AppType
        AppName = $_.AppName
        AssignedTo = $_.AssignedTo
        AssignmentType = $_.AssignmentType
        AssignmentMode = $_.AssignmentMode
    }
}
$ExportArray | Export-Csv -Path "$Csvfile" -NoTypeInformation
