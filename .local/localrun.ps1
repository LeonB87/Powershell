<#
.SYNOPSIS
    Script for running local validation and documenation generation

.DESCRIPTION
    Script for running local validation and documenation generation. Run before each commit

.EXAMPLE
    .\LocalRun.ps1

#>
BEGIN {
    Write-Host "## Starting the local run of the analyzer scripts!" -ForegroundColor DarkBlue
}
PROCESS {
    Write-Host "## Processing the local PowerShell script and there operation" -ForegroundColor Green

    Write-Host "### Invoke script analyzer" -ForegroundColor Blue
    ./utilities/Invoke-ScriptAnalyzer.ps1  -Paths "Powershell\scripts" -Local

    Write-Host "### Invoke new Markdown documentation - utilities" -ForegroundColor Blue
    ./utilities/New-MDPowerShellScripts.ps1 -ScriptFolder "..\Powershell\scripts\" -OutputFolder "..\Powershell\scripts\"  -KeepStructure $true

}
END {
    Write-Host "## Ending the local run of the analyzer scripts!" -ForegroundColor DarkBlue
}