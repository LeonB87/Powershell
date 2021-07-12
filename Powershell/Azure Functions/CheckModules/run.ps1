using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.


$modules = Get-Module -ListAvailable
$modulesInfo = @()

foreach ($module in $modules) {
    $modulesInfo += [PSCustomObject]@{
        Name        = $module.Name
        Path        = $module.Path
        Description = $module.Description
    }
}
$version = ("$($PSVersionTable.Psversion) - $($PSversiontable.PSEdition)")

$responseBody = @{
    modules   = $modulesInfo
    PSversion = $version
} | ConvertTo-Json -Depth 10

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $responseBody
    })
