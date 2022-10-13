

<#
    .SYNOPSIS
    This scripts helps validating your powershell scripts in a CI pipeline

    .DESCRIPTION
    This scripts helps validating your powershell scripts in a CI pipeline. enter a path to the folder containing your .PS1 files
    When errors or warnings are found, a write-errors/warning is outputted.

    .PARAMETER path
    The path of the scripts. This folder and subfolders are searched with the filter *.ps1

    .EXAMPLE
    Invoke-PSScriptAnalyzerCI -path C:\src\myPowershellScripts

    .NOTES
    Version:        1.0.0;
    Author:         Léon Boers;
    Creation Date:  11-10-2022;
    Purpose/Change: Initial script development;

    #>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$path
)
BEGIN {
    Import-Module psScriptAnalyzer | Out-Null
    $module = Get-Module psScriptAnalyzer

    Write-Output ("Starting to analyze scripts in folder:   '$($path)'")

    if (-not $null -eq $module){
        Write-Output ("PSScriptAnalyzer Version:                '$($module.Version.ToString())'")
    }

    $scripts = Get-ChildItem -Path $path -Recurse -Filter "*.ps1*"

    Write-Output ("Found '$($scripts.count)' scripts in folder '$($path)'")

    $analysisResult = @{
        errors      = 0
        warnings    = 0
        information = 0
    }
}
PROCESS {
    function Get-Results {
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [object]$result

        switch ($result.Severity) {
            'Error' {
                $analysisResult.errors++
            }
            'Warning' {
                $analysisResult.warnings++
            }
            'Information' {
                $analysisResult.information++
            }
            Default {
                Write-Error ("Unknown result Severity '$($result.Severity)'")
            }
        }
    }

    Function Export-NUnitXml {
        <#
        .SYNOPSIS
            Takes results from PSScriptAnalyzer and exports them as a Pester test results file (NUnitXml format).

        .DESCRIPTION
            Takes results from PSScriptAnalyzer and exports them as a Pester test results file (NUnit XML schema).
            Because the generated file in NUnit-compatible, it can be consumed and published by most continuous integration tools.

            Source of this script: https://github.com/MathieuBuisson/PowerShell-DevOps/blob/master/Export-NUnitXml/Export-NUnitXml.psm1
        #>
            [CmdletBinding()]
            Param (
                [Parameter(Mandatory, Position=0)]
                [AllowNull()]
                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]$ScriptAnalyzerResult,

                [Parameter(Mandatory, Position=1)]
                [string]$Path
            )

            $TotalNumber = If ($ScriptAnalyzerResult) { $ScriptAnalyzerResult.Count -as [string] } Else { '1' }
            $FailedNumber = If ($ScriptAnalyzerResult) { $ScriptAnalyzerResult.Count -as [string] } Else { '0' }
            $Now = Get-Date
            $FormattedDate = Get-Date $Now -Format 'yyyy-MM-dd'
            $FormattedTime = Get-Date $Now -Format 'T'
            $User = $env:USERNAME
            $MachineName = $env:COMPUTERNAME
            $Cwd = $pwd.Path
            $UserDomain = $env:USERDOMAIN
            $OS = Get-CimInstance -ClassName Win32_OperatingSystem
            $Platform = $OS.Caption
            $OSVersion = $OS.Version
            $ClrVersion = $PSVersionTable.PSVersion.ToString()
            $CurrentCulture = (Get-Culture).Name
            $UICulture = (Get-UICulture).Name

            Switch ($ScriptAnalyzerResult) {
                $Null { $TestResult = 'Success'; $TestSuccess = 'True'; Break}
                Default { $TestResult = 'Failure'; $TestSuccess = 'False'}
            }

            $Header = @"
<?xml version="1.0" encoding="utf-8" standalone="no"?>
        <test-results xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="nunit_schema_2.5.xsd" name="PSScriptAnalyzer" total="$TotalNumber" errors="0" failures="$FailedNumber" not-run="0" inconclusive="0" ignored="0" skipped="0" invalid="0" date="$FormattedDate" time="$FormattedTime">
          <environment user="$User" machine-name="$MachineName" cwd="$Cwd" user-domain="$UserDomain" platform="$Platform" nunit-version="2.5.8.0" os-version="$OSVersion" clr-version="$ClrVersion" />
          <culture-info current-culture="$CurrentCulture" current-uiculture="$UICulture" />
          <test-suite type="Powershell" name="PSScriptAnalyzer" executed="True" result="$TestResult" success="$TestSuccess" time="0.0" asserts="0">
            <results>
              <test-suite type="TestFixture" name="PSScriptAnalyzer" executed="True" result="$TestResult" success="$TestSuccess" time="0.0" asserts="0" description="PSScriptAnalyzer">
                <results>`n
"@

            $Footer = @"
                </results>
              </test-suite>
            </results>
          </test-suite>
        </test-results>
"@

            If ( -not($ScriptAnalyzerResult) ) {

                $TestDescription = 'All PowerShell files pass the specified PSScriptAnalyzer rules'
                $TestName = "PSScriptAnalyzer.{0}" -f $TestDescription

                $Body = @"
                  <test-case description="$TestDescription" name="$TestName" time="0.0" asserts="0" success="True" result="Success" executed="True" />`n
"@
            }
            Else { # $ScriptAnalyzerResult is not null
                $Body = [string]::Empty
                Foreach ( $Result in $ScriptAnalyzerResult ) {

                    $TestDescription = "Rule name : $($Result.RuleName)"
                    $TestName = "PSScriptAnalyzer.{0} - {1} - Line {2}" -f $TestDescription, $($Result.ScriptName), $($Result.Line.ToString())

                    # Need to Escape these otherwise we can end up with an invalid XML if the Stacktrace has non XML friendly chars like &, etc
                    $Line = [System.Security.SecurityElement]::Escape($Result.Line)
                    $ScriptPath = [System.Security.SecurityElement]::Escape($Result.ScriptPath)
                    $Text = [System.Security.SecurityElement]::Escape($Result.Extent.Text)
                    $Severity = [System.Security.SecurityElement]::Escape($Result.Severity)

                    $TestCase = @"
                  <test-case description="$TestDescription" name="$TestName" time="0.0" asserts="0" success="False" result="Failure" executed="True">
                    <failure>
                      <message>$($Result.Message)</message>
                      <stack-trace>at line: $($Line) in $($ScriptPath)
                $($Line): $($Text)
         Rule severity : $($Severity)
                      </stack-trace>
                    </failure>
                  </test-case>`n
"@

                    $Body += $TestCase
                }
            }
            $OutputXml = $Header + $Body + $Footer

            # Checking our output is a well formed XML document
            Try {
                $XmlCheck = [xml]$OutputXml
            }
            Catch {
                Throw "There was an problem when attempting to cast the output to XML : $($_.Exception.Message)"
            }
            $OutputXml | Out-File -FilePath $Path -Encoding utf8 -Force
        }

    foreach ($script in $scripts) {
        Write-Output ("Analyzing '$($script.FullName)'")

        $results = Invoke-ScriptAnalyzer -Path $script.FullName -ReportSummary
        $combinedScriptAnalyzerResult += $results
        foreach ($result in $results ) {
            Get-Results -result $result
        }

    }

}
END {
    Write-Output ("Final result:")
    if ($analysisResult.errors -ne 0) {
        Write-Error ("There were '$($analysisResult.errors)' error(s) found in the script(s)")
    }
    else {
        Write-Output ("No errors were found")
    }
    if ($analysisResult.warnings -ne 0) {
        Write-Warning ("There are '$($analysisResult.warnings)' warning(s) found in the script(s)")
    }
    else {
        Write-Output ("No warnings were found")
    }
    if ($analysisResult.information -ne 0) {
        Write-Information ("There were '$($analysisResult.errors)' message(s) found in the script(s)")
    }
    else {
        Write-Output ("No messages were found")
    }

    Write-output ("Exporting to NUnit XML")
    Export-NUnitXml -ScriptAnalyzerResult $combinedScriptAnalyzerResult -Path '.\ScriptAnalyzerResult.xml'

}