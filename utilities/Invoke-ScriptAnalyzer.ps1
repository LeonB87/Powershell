<#
.SYNOPSIS
    Validates PowerShell script files via the PSScriptAnalyzer and exports the results  as a Pester test results file (NUnitXml format).

.DESCRIPTION
    Validates PowerShell script files via the PSScriptAnalyzer and exports the results  as a Pester test results file (NUnitXml format).
    Because the generated file in NUnit-compatible, it can be consumed and published by most continuous integration tools.
    Author: Maik van der Gaag
    Date: 27-03-2020


.PARAMETER Paths
    The folder that contains the json files

.PARAMETER Local
    Is is a local run or online

.NOTES
    Version:        1.0.0;

.EXAMPLE
    .\Invoke-ScriptAnalyzer.ps1 -Paths "C:\templates\"

#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][String]$Paths,
    [Parameter(Mandatory = $false)][switch]$Local
)

BEGIN {
    try {
        function Export-NUnitXml {
            [OutputType([System.Xml.XmlDocument])]
            Param (
                [Parameter(Mandatory, Position = 0)][AllowNull()][object[]]$ScriptAnalyzerResult,
                [Parameter(Mandatory, Position = 1)][string]$Path,
                [Parameter(Mandatory = $false, Position = 2)][string]$Time = "0.0"
            )
            BEGIN {
                $clrVersion = if ($null -eq $PSVersionTable.CLRVersion) { "" }else {$PSVersionTable.CLRVersion.ToString()}
                $totalNumber = If ($ScriptAnalyzerResult) { $ScriptAnalyzerResult.Count -as [string] }else { "1" }
                $formattedDate = Get-Date -Format 'yyyy-MM-dd'
                $formattedTime = Get-Date -Format 'T'
                $user = $env:USERNAME
                $machineName = $env:COMPUTERNAME
                $cwd = $pwd.Path
                $userDomain = $env:USERDOMAIN
                $OS = $PSVersionTable.OS
                $platform = $OS.Caption
                $OSVersion = $OS.Version
                $currentCulture = (Get-Culture).Name
                $UICulture = (Get-UICulture).Name
            }
            PROCESS {
                Switch ($ScriptAnalyzerResult) {
                    $Null {
                        $testResult = 'Success'; $testSuccess = 'True'; Break
                    }
                    Default {
                        $testResult = 'Failure'; $testSuccess = 'False'
                    }
                }
                $header = @"
<?xml version="1.0" encoding="utf-8" standalone="no"?>
                            <test-results xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="nunit_schema_2.5.xsd" name="PSScriptAnalyzer" total="$totalNumber" errors="0" failures="failedNumber" not-run="0" inconclusive="0" ignored="0" skipped="0" invalid="0" date="$formattedDate" time="$formattedTime">
                              <environment user="$user" machine-name="$machineName" cwd="$cwd" user-domain="$userDomain" platform="$platform" nunit-version="2.5.8.0" os-version="$OSVersion" clr-version="$clrVersion" />
                              <culture-info current-culture="$currentCulture" current-uiculture="$UICulture" />
                              <test-suite type="Powershell" name="PSScriptAnalyzer" executed="True" result="$testResult" success="$testSuccess" time="$Time" asserts="0">
                                <results>
                                  <test-suite type="TestFixture" name="PSScriptAnalyzer" executed="True" result="$testResult" success="$testSuccess" time="$Time" asserts="0" description="PSScriptAnalyzer">
                                    <results>`n
"@
                $footer = @"
                         </results>
                           </test-suite>
                          </results>
                        </test-suite>
                      </test-results>
"@
                if (-not($ScriptAnalyzerResult)) {
                    $testDescription = 'All PowerShell files pass the specified PSScriptAnalyzer rules'
                    $testName = "PSScriptAnalyzer.{0}" -f $TestDescription
                    $Body = @"
                        <test-case description="$testDescription" name="$testName" time="$time" asserts="0" success="True" result="Success" executed="True" />`n
"@
                } else {
                    $Body = [string]::Empty
                    foreach ($result in $ScriptAnalyzerResult ) {
                        $testDescription = "Rule name : $($result.RuleName)"
                        $line = if ($null -eq $result.Line) { "not known" } else { $result.Line.ToString() }
                        $testName = ("PSScriptAnalyzer.$($testDescription) - $($result.ScriptName) - Line $($line)")
                        $line = [System.Security.SecurityElement]::Escape($result.Line)
                        $scriptPath = [System.Security.SecurityElement]::Escape($result.ScriptPath)
                        $text = [System.Security.SecurityElement]::Escape($result.Extent.Text)
                        $severity = [System.Security.SecurityElement]::Escape($result.Severity)
                        $testCase = @"
                            <test-case description="$testDescription" name="$testName" time="$Time" asserts="0" success="False" result="Failure" executed="True">
                            <failure>
                            <message>$($Result.Message)</message>
                            <stack-trace>at line: $($line) in $($scriptPath)
                                        $($line): $($text)
                                        Rule severity : $($severity)
                            </stack-trace>
                            </failure>
                        </test-case>`n
"@
                        $Body += $testCase
                    }
                }
                $outputXml = ("$($header) $($body) $($footer)")
                try {
                    [xml]$outputXml
                } catch {
                    Throw ("There was an problem when attempting to cast the output to XML : $($_.Exception.Message)")
                }
                $outputXml | Out-File -FilePath $Path -Encoding utf8 -Force
            }
            END {
                Write-Output "File exporting to NUnitXML finished"
            }
        }
        Write-Information "Install required modules started" -InformationAction Continue
        #Declare modules here
        $ModulesToInstall = @(
            @{
                Name           = 'PSScriptAnalyzer'
                MinimumVersion = '1.18.3'
                Repository     = 'PSGallery'
            }
        )
        #Install Missing Modules
        $InstallModule_BaseParams = @{
            Scope              = 'CurrentUser'
            AllowClobber       = $true
            SkipPublisherCheck = $true
            Force              = $true
            Confirm            = $false
        }
        foreach ($mod in $ModulesToInstall) {
            $PSGetModule = Get-Module -FullyQualifiedName @{ModuleName = $mod.Name; ModuleVersion = $mod.MinimumVersion } -ListAvailable -Refresh
            if (-not $PSGetModule) {
                Write-Information "Install required modules in progress. Module: $($mod.Name)/$($Mod.MinimumVersion) installing..." -InformationAction Continue
                $InstallModule_Params = $InstallModule_BaseParams + $mod
                $null = Install-Module @InstallModule_Params -ErrorAction Stop
            } else {
                Write-Information "Install required modules in progress. Module: $($mod.Name)/$($Mod.MinimumVersion) skipped, already installed" -InformationAction Continue
            }
            $Null = Import-Module -MinimumVersion $mod.MinimumVersion -Name $Mod.Name -ErrorAction Stop -Force
        }
        Write-Information "Install required modules completed" -InformationAction Continue
    } catch {
        throw "Install required modules failed. Details: $_"
    }
}
PROCESS {
    #Invoke the validation
    try {
        if ($Paths.Contains(',')) {
            $pathItems = $Paths.Split(',')
        } else {
            $pathItems = @($Paths)
        }

        Write-Information "Invoke validation started" -InformationAction Continue

        $stopwatch = [system.diagnostics.stopwatch]::StartNew()
        $stopwatch.Start()

        foreach ($path in $pathItems) {
            $PathInfo = Split-path -Path $PSScriptRoot -Parent | join-path -ChildPath $path
            Write-Information "## Analyze folder: $PathInfo - started" -InformationAction Continue

            $ScriptAnalyzerResult = Invoke-ScriptAnalyzer -Path $PathInfo -Recurse -Settings "$($PSScriptRoot)\analysersettings.psd1" -Verbose
        }

        if ($stopwatch.IsRunning) {
            $stopwatch.Stop()
            $timerunning = $stopwatch.Elapsed
        }

        if ($Local) {

            if ($ScriptAnalyzerResult) {
                Write-Output "Results found: $timerunning" -ForegroundColor Yellow
            }
            $ScriptAnalyzerResult
        } else {
            Write-Information "Exporting to NUnit XML file" -InformationAction Continue
            Export-NUnitXml -ScriptAnalyzerResult $ScriptAnalyzerResult -Path '.\ScriptAnalyzerResult.xml' -Time $timerunning
            Write-Information "Exporting done!" -InformationAction Continue
        }
    } catch {
        Write-Error "Something went wrong will processing the PowerShell files: $_"
    }
}
END {
    Write-Output "Done processing the PowerShell scripts"
}