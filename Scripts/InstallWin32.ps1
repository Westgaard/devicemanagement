[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [ValidateSet('Install','Uninstall')]
    [string]$DeploymentType = 'Install'
)

 

If ($deploymentType -ine 'Uninstall') {
    Try {
        .\ServiceUI.exe -Process:explorer.exe Deploy-Application.exe
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        $ErrorMessage
    }
}
ElseIf ($deploymentType -ieq 'Uninstall')
{
    Foreach ($targetprocess in $targetprocesses) {
        $Username = $targetprocesses.GetOwner().User
        Write-output "$Username logged in, running with SerivuceUI"
    }
    Try {
        .\ServiceUI.exe -Process:explorer.exe Deploy-Application.exe -DeploymentType "Uninstall"
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        $ErrorMessage
    }
}
Write-Output "Install Exit Code = $LASTEXITCODE"
Exit $LASTEXITCODE
