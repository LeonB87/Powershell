



function New-ApplicationInsightClient {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "The Application Insights Instrumentation Key that is used to send the messages to the correct Application Insights Instance.")]
        [ValidateNotNullOrEmpty()]
        [Guid]
        $InstrumentationKey
    )

    $AIClient = [Microsoft.ApplicationInsights.TelemetryClient]::new()
    $AIClient.InstrumentationKey = $InstrumentationKey

    return $AIClient
}

function Set-ApplicationInsightClientInformation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $AIClient,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $User
    )
    begin {
        if (-not $null -eq $User) {
            Write-Verbose ("Received 'User' properties to set in the client")
        }
    }

    process {
        if (-not $null -eq $User) {

            foreach ($property in $AIClient.Context.User.psobject.Properties.name) {
                Write-Verbose ("Checking property '$($property)' in supplied hashtable")
                if (-not [string]::IsNullOrWhiteSpace($User[$property])) {
                    Write-Verbose ("Found property '$($property)' with a value. Changing value from '$($AIClient.Context.User.$property)' to '$($User[$property])'")

                    $AIClient.Context.User.$property = $User[$property]
                }
            }
        }
    }

    end {
        return $AIClient
    }

}

<#

$client.Context.User.Id = $Env:UserName
$Client.Context.Session.Id = $PID

# Trace
#[Microsoft.ApplicationInsights.DataContracts.SeverityLevel]
$client.TrackTrace("Hello, World!", "Error")
$Client.Flush()

# Metric
$client.TrackMetric("Metric", (Get-Random))
$Client.Flush()

# Metric with Properties
$dct = [System.Collections.Generic.Dictionary[string, string]]::new()
$dct.Add("LANG", $Env:LANG)
$Client.Flush()

$client.TrackMetric("Metric", (Get-Random), $dct)
$Client.Flush()

# PageView
$client.TrackPageView($MyInvocation.MyCommand.Name)
$Client.Flush()

# Exceptions
$client.TrackException([System.Exception]::new("Hello"))
$Client.Flush()

# Requests
function Measure-AICommand {

    param(
        $Name,
        $ScriptBlock
    )

    $sw = [System.Diagnostics.Stopwatch]::new()
    $sw.Start()

    $Status = "OK"
    try {
        & $ScriptBlock
    }
    catch {
        $status = $_.ToString();
    }

    $client.TrackRequest($name, (Get-Date), $sw.Elapsed, $status, $Status -eq "OK")
    $Client.Flush()

    $Sw.Stop()
}

Measure-AICommand -ScriptBlock {
    Start-Sleep (Get-Random -Min 1 -Max 5)
} -Name 'Sleeping'

# Dependency

function Test-Url {

    param(
        $Url
    )

    $sw = [System.Diagnostics.Stopwatch]::new()
    $sw.Start()

    $Status = $true
    try {
        Invoke-WebRequest -Uri $Url
    }
    catch {
        $Status = $false
    }

    $Client.TrackDependency("HTTP", $Url, "", (Get-Date), $sw.Elapsed, $status)
    $Client.Flush()

    $Sw.Stop()
}

Test-Url -Url 'https://www.ironmansoftware.com'
#>