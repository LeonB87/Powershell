<#
.SYNOPSIS
This is a test function within Azure Functions Powershell

.DESCRIPTION
This is a test function within Azure Functions Powershell

.PARAMETER Request
This is a default parameter for Azure Powershell functions that holds the body of the request

.PARAMETER TriggerMetadata
This is a default parameter for Azure Powershell functions that holds additional information regarding the request.

.NOTES
Version:        1.0.0;
Author:         Léon Boers;
Creation Date:  21-08-2021;
1.0.0:          Initial function development;

.COMPONENT
Module:Tested Version;
Az.Accounts:2.5.2;
#>
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)


BEGIN {

    check-mycustommodule
}
PROCESS {

}
END {
    Disconnect-AzAccount | Out-Null
    if ($env:MSI_SECRET) {
        Disable-AzContextAutosave -Scope Process | Out-Null
        Connect-AzAccount -Identity | Out-Null
    }

    if ([string]::IsNullOrEmpty($collectedErrors)) {
        $success = $true
        $statusCode = [HttpStatusCode]::Ok
    }
    else {
        $statusCode = [HttpStatusCode]::InternalServerError
    }

    $returnBody = @{
        success = $success
        errors  = $collectedErrors
        output  = $output
    } | ConvertTo-Json -Depth 10

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = $statusCode
            Body       = $returnBody
        })
}