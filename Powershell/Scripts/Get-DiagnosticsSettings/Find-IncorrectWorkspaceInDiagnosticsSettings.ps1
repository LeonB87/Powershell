#module {az.resources}

function Find-IncorrectWorkspaceInDiagnosticsSettings {
    <#
    .SYNOPSIS
    This is a powershell script template

    .DESCRIPTION
    This is a very simple powershell script template to get started

    .PARAMETER targetLogAnalyticsWorkspaceId

    .NOTES
    Version:        1.0.0;
    Author:         Léon Boers;
    Creation Date:  14-09-2022;
    Purpose/Change: Initial script development;

    #>
    [cmdletBinding(DefaultParameterSetName = "default")]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = "default")]
        [ValidateNotNullOrEmpty()]
        [string]$targetLogAnalyticsWorkspaceId
    )
    BEGIN {
        $nonCompliantResources = [System.Collections.ArrayList]::new()

        $resources = Get-AzResource -ResourceId '/subscriptions/2a874642-af24-4656-9ca0-841d112c8aed/resourceGroups/oiko-rpauipath-a/providers/Microsoft.KeyVault/vaults/oiko-rpauipath-a-vm'

        Write-Output ("Found '$($resources.count)' Resource(s)")
    }
    PROCESS {

        foreach ($resource in  $resources) {
            Write-Verbose ("Processing '$($resource)'")

            $diagnosticSettingCategory = Get-AzDiagnosticSettingCategory -TargetResourceId $resource.id -ErrorAction SilentlyContinue

            if (-not $null -eq $diagnosticSettingCategory) {
                Write-Verbose ("Found diagnostic category. checking current setting.")
                $diagnosticSettings = Get-AzDiagnosticSetting -ResourceId $resource.ResourceId

                if (-not $null -eq $diagnosticSettings) {
                    Write-Verbose ("Found Diagnostic Settings that are set")

                    if (-not $diagnosticSettings.WorkspaceId -eq $targetLogAnalyticsWorkspaceId) {
                        Write-Output ("The resource $($resource.id) is not pointing to the centralized workspace.")
                        $nonCompliantResources.Add($resource.id)
                    }

                }

            }

        }

    }
    END {
        Write-Output ("Found a total of '$($nonCompliantResources.Count)' resource(s) that are pointing to another workspace")
    }

}

Find-IncorrectWorkspaceInDiagnosticsSettings -targetLogAnalyticsWorkspaceId '/subscriptions/dd4a092a-ba65-472c-b765-f938dbaaccb8/resourcegroups/oiko-p-rg-shared/providers/microsoft.operationalinsights/workspaces/oiko-sentinel-p-la'