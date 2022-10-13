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

    if (-not $null -eq $module) {
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

    foreach ($script in $scripts) {
        Write-Output ("Analyzing '$($script.FullName)'")


        $parameters = @{
            Path = $script.FullName
        }
        $results = Invoke-ScriptAnalyzer -Path $path -ReportSummary

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
}