using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

Get-Command -Module mycystommodule

$result1 = check-mycustommodule
$result2 = Get-ModuleReply

$responseBody = @{
    result1 = $result1
    result2 = $result2
} | ConvertTo-Json -Depth 10

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $responseBody
    })
