function New-ApplicationInsightsClient {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "The Application Insights Instrumentation Key that is used to send the messages to the correct Application Insights Instance.")]
        [ValidateNotNullOrEmpty()]
        [Guid]
        $InstrumentationKey
    )

    $Client = [Microsoft.ApplicationInsights.TelemetryClient]::new()
    $Client.InstrumentationKey = $InstrumentationKey

    $defaultUserInformation = @{
        AuthenticatedUserId = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        UserAgent           = ("PS $($psversiontable.PSEdition) $($psversiontable.PSVersion)")
    }

    $defaultDeviceInformation = @{
        ID              = (Get-CimInstance -Class Win32_ComputerSystemProduct).UUID
        OperatingSystem = $psversiontable.OS

    }

    $client = Set-ApplicationInsightsClientInformation -UserInformation $defaultUserInformation -DeviceInformation $defaultDeviceInformation -Client $Client

    return $Client
}

function Confirm-ApplicationInsightsClient {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client
    )

    [bool] $isValid = $true
    Write-Verbose ("Checking if the Application Insights Client is valid...")

    if ([string]::IsNullOrWhiteSpace($client.InstrumentationKey)) {
        Write-Verbose ("The Instrumentation Key is not set.")
        $isValid = $false
    }

    if ($client.Isenabled() -eq $false) {
        Write-Verbose ("The Application Insights Client is not enabled.")
        $isValid = $false
    }

    if ($isValid -eq $true) {
        Write-Verbose ("The Application Insights Client is valid.")
    }
    else {
        throw ("The Application Insights Client is not valid.")
    }
}

function Set-ApplicationInsightsClientInformation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $UserInformation,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $DeviceInformation
    )
    begin {
        if (-not $null -eq $UserInformation) {
            Write-Verbose ("Received 'User' properties to set in the client")
        }

        if (-not $null -eq $DeviceInformation) {
            Write-Verbose ("Received 'Device' properties to set in the client")
        }
    }

    process {
        if (-not $null -eq $UserInformation) {

            foreach ($property in $Client.Context.User.psobject.Properties.name) {
                Write-Verbose ("Checking property '$($property)' in supplied hashtable")
                if (-not [string]::IsNullOrWhiteSpace($UserInformation[$property])) {
                    Write-Verbose ("Found property '$($property)' with a value. Changing value from '$($Client.Context.User.$property)' to '$($UserInformation[$property])'")

                    $Client.Context.User.$property = $UserInformation[$property]
                }
            }
        }

        if (-not $null -eq $DeviceInformation) {

            foreach ($property in $Client.Context.Device.psobject.Properties.name) {
                Write-Verbose ("Checking property '$($property)' in supplied hashtable")
                if (-not [string]::IsNullOrWhiteSpace($DeviceInformation[$property])) {
                    Write-Verbose ("Found property '$($property)' with a value. Changing value from '$($Client.Context.Device.$property)' to '$($DeviceInformation[$property])'")

                    $Client.Context.Device.$property = $DeviceInformation[$property]
                }
            }
        }
    }

    end {
        return $Client
    }

}

function Write-ApplicationInsightsTrace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client,

        [Parameter(Mandatory = $true)]
        [string]
        $Message,

        [Parameter(Mandatory = $false)]
        [validateSet('Information', 'Verbose', 'Warning', 'Error', 'Critical')]
        [string]
        $SeverityLevel = "information",

        [Parameter(Mandatory = $false, HelpMessage = "This is a dictionary<string, string> with additional information that will be added as 'customDimensions' in Application Insights")]
        [System.Collections.Generic.Dictionary[string, string]]
        $properties
    )
    BEGIN {
        Write-Verbose ("Received '$($SeverityLevel)' severity level for the message '$($Message)'")

        if ($properties.Count -ge 1) {
            Write-Verbose ("Received '$($properties.Count)' properties to add to the message.")
        }

        Confirm-ApplicationInsightsClient $client
    }
    PROCESS {
        if ($properties.Count -ge 1) {
            $Client.TrackTrace($Message, [Microsoft.ApplicationInsights.DataContracts.SeverityLevel]::$($SeverityLevel), $properties)
        }
        else {
            $Client.TrackTrace($Message, [Microsoft.ApplicationInsights.DataContracts.SeverityLevel]::$($SeverityLevel))
        }

    }
    END {
        $Client.Flush()
    }
}

function Write-ApplicationInsightsMetric {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [Double]
        $Metric,

        [Parameter(Mandatory = $false, HelpMessage = "This is a dictionary<string, string> with additional information that will be added as 'customDimensions' in Application Insights")]
        [System.Collections.Generic.Dictionary[string, string]]
        $properties
    )
    BEGIN {

        if ($properties.Count -ge 1) {
            Write-Verbose ("Received '$($properties.Count)' properties to add to the message.")
        }
    }
    PROCESS {
        if ($properties.Count -ge 1) {
            $client.TrackMetric($name, $Metric, $properties)
        }
        else {
            $client.TrackMetric($name, $Metric)
        }

    }
    END {
        $Client.Flush()
    }
}

function Write-ApplicationInsightsException {
    [CmdletBinding(DefaultParameterSetName = "Exception")]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client,

        [Parameter(Mandatory = $true, ParameterSetName = "Exception")]
        [System.Exception]
        $Exception,

        [Parameter(Mandatory = $true, ParameterSetName = "StringException")]
        [string]
        $ExceptionString,

        [Parameter(Mandatory = $false, HelpMessage = "This is a dictionary<string, double> with additional information that will be added as 'customMeasurements' in Application Insights")]
        [System.Collections.Generic.Dictionary[string, double]]
        $Metrics = [System.Collections.Generic.Dictionary[string, double]]::new(),

        [Parameter(Mandatory = $false, HelpMessage = "This is a dictionary<string, string> with additional information that will be added as 'customDimensions' in Application Insights")]
        [System.Collections.Generic.Dictionary[string, string]]
        $properties = [System.Collections.Generic.Dictionary[string, string]]::new()
    )
    BEGIN {
        Write-Verbose ("Running in Parameterset '$($PSCmdlet.ParameterSetName)'")

        if ($PSCmdlet.ParameterSetName -eq "StringException") {
            $Exception = [System.Exception]::new($ExceptionString)
        }
    }
    PROCESS {
        $client.TrackException($Exception, $properties, $Metrics)

        $client.TrackExce
    }
    END {
        $Client.Flush()
    }
}

function Write-ApplicationInsightRequest {

}


$client = New-ApplicationInsightsClient -InstrumentationKey c323cf10-da34-4a73-9eac-47dad64d840b
Write-ApplicationInsightsTrace -Client $client -Message "This is a test message" -SeverityLevel "Information"


$dictionary = [System.Collections.Generic.Dictionary[string, string]]::new()

$dictionary.Add("FirstName", "John")
$dictionary.Add("LastName", "Doe")

# Write-ApplicationInsightsTrace -Client $client -Message "This is a test message with properties" -SeverityLevel "Information" -properties $dictionary

# Write-ApplicationInsightsMetric -Client $client -Name 'My Metric Name' -Metric 100
# Write-ApplicationInsightsMetric -Client $client -Name 'My Metric Name' -Metric 100 -properties $dictionary

# Write-ApplicationInsightsException -ExceptionString "This happend!" -Client $client -properties $dictionary

# $metrics = [System.Collections.Generic.Dictionary[string, double]]::new()

# $metrics.Add("MyMetric", 100)
# $metrics.Add("MyMetric 2", 150)

# try {
#     0 / 0
# }
# catch {
#     $caughtException = $_.Exception
# }

# Write-ApplicationInsightsException -Exception $caughtException -Client $client -Metrics $metrics -properties $dictionary


# # PageView
# $client.TrackPageView($MyInvocation.MyCommand.Name)
# $Client.Flush()

# # Requests
# function Measure-AICommand {

#     param(
#         $Name,
#         $ScriptBlock
#     )

#     $sw = [System.Diagnostics.Stopwatch]::new()
#     $sw.Start()

#     $Status = "OK"
#     try {
#         & $ScriptBlock
#     }
#     catch {
#         $status = $_.ToString();
#     }

#     $client.TrackRequest($name, (Get-Date), $sw.Elapsed, $status, $Status -eq "OK")
#     $Client.Flush()

#     $Sw.Stop()
# }

# Measure-AICommand -ScriptBlock {
#     Start-Sleep (Get-Random -Min 1 -Max 5)
# } -Name 'Sleeping'

# # Dependency

# function Test-Url {

#     param(
#         $Url
#     )

#     $sw = [System.Diagnostics.Stopwatch]::new()
#     $sw.Start()

#     $Status = $true
#     try {
#         Invoke-WebRequest -Uri $Url
#     }
#     catch {
#         $Status = $false
#     }

#     $Client.TrackDependency("HTTP", $Url, "", (Get-Date), $sw.Elapsed, $status)
#     $Client.Flush()

#     $Sw.Stop()
# }

# Test-Url -Url 'https://www.ironmansoftware.com'
# #>