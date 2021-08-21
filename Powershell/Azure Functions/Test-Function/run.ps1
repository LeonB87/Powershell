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
#>
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)


BEGIN {
    $success = $false
    $collectedErrors = ''

    $schemaFile = ("$($TriggerMetadata['FunctionDirectory'])\schema.json")

    if (![string]::IsNullOrEmpty($Request.Body)) {
        if (Test-Path $schemaFile) {
            if (!((Get-Content $schemaFile).length -eq 0)) {
                $continueScript = Get-SchemaValidationResult -Body $Request.Body -SchemaFile $schemaFile
                if (!($continueScript)) {
                    $message = ("The Body in the request does not match the function schema. Please read the documentation.")
                    Write-Error -Message $message ; $collectedErrors += $message
                }
            } #end if !((Get-Content $schemaFile).length -eq 0)
            else {
                $message = ("The schema file seems to be empty.")
                Write-Error -Message $message ; $collectedErrors += $message
            }
        } # end if Test-Path $schemaFile
        else {
            $message = ("The schema.json file cannot be found.")
            Write-Error -Message $message ; $collectedErrors += $message
        }
    } #end if ![string]::IsNullOrEmpty($Request.Body)

    if ($continueScript) {

        [string]$inputString = $Request.Body.string
        [string]$stringFixedInput = $Request.Body.stringFixedInput
        [array]$inputListArray = $Request.Body.listArray
        [string]$emailAddress = $Request.Body.emailAddress
        [array]$azureVMList = $Request.Body.azureVMList

        Write-Information ('Received the following information from the body')
        Write-Information ("string:             $($inputString)")
        Write-Information ("stringFixedInput:             $($stringFixedInput)")
        Write-Information ("inputListArray Count:     $($inputListArray.count)")
        Write-Information ("inputListArray data:     $($inputListArray)")
        Write-Information ("emailAddress:     $($emailAddress)")
        Write-Information ("azureVMList count:     $($azureVMList.count)")

        if ($azureVMList.count -ge 1) {
            foreach ($vm in $azureVMList) {
                Write-Information ("vmName:     $($vm.vmName)")
            }
        }

    }


}
PROCESS {
    if ($continueScript) {

    }
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
    } | ConvertTo-Json -Depth 10

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = $statusCode
            Body       = $returnBody
        })
}