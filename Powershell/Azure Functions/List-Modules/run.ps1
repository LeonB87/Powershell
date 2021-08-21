<#
.SYNOPSIS
Returns the azure modules present in the web app

.DESCRIPTION
Returns the azure modules present in the web app including the powershell version running on the webapp.

.PARAMETER Request
This is a default parameter for Azure Powershell functions that holds the body of the request

.PARAMETER TriggerMetadata
This is a default parameter for Azure Powershell functions that holds additional information regarding the request.

.NOTES
Version:        1.0.0;
Author:         Léon Boers;
Creation Date:  09-08-2021;
1.0.0:          Initial function development;

.COMPONENT
Module:Tested Version;
#>
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host 'PowerShell HTTP trigger. Updating and listing all available modules defined in the requirements.psd1 file.'

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

$modules = $(Get-Module -ListAvailable | Select-Object Name, Version, Path)

$moduleArray = @()
$managedModuleArray = @()
$defaultModulesArray = @()

foreach ($module in $modules) {
    $moduleCustomObject = [PSCustomObject][ordered]@{
        Name    = $module.Name
        Version = $module.Version.ToString()
        Path    = $module.Path
    }

    if ($module.Path -like ('*ManagedDependencies*')) {
        $managedModuleArray += $moduleCustomObject
    }
    elseif ($module.Path -like ('*wwwroot*')) {
        $moduleArray += $moduleCustomObject
    }
    else {
        $defaultModulesArray += $moduleCustomObject
    }

}

$modulesBody = @{
    customModules  = $moduleArray
    managedModules = $managedModuleArray
    defaultModules = $defaultModulesArray
}

$returnBody = @{
    count             = $modules.Count
    modules           = $modulesBody
    PowershellVersion = ("$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)")
}

$returnBody = $returnBody | ConvertTo-Json -Depth 3

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $returnBody
    })