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


    write-host "### Copying GitHUB TOC script to utilities folder."
    Copy-Item -Path .\Powershell\Scripts\Generate-GithubTOC\Generate-githubTOC.ps1 -Destination .\utilities -Force

    Write-Host "### Invoke new Markdown documentation - Script" -ForegroundColor Blue
    ./utilities/New-MDPowerShellScripts.ps1 -ScriptFolder ".\Powershell\scripts\" -OutputFolder ".\Powershell\scripts\"  -KeepStructure $true -IncludeWikiTOC $true -WikiTOCStyle "Github"

    Write-Host "### Invoke new Markdown documentation - Central" -ForegroundColor Blue
    ./utilities/New-MDPowerShellScripts.ps1 -ScriptFolder ".\Powershell\scripts\" -OutputFolder ".\Powershell\scripts\" -KeepStructure $true -WikiSummaryOutputfileName "readme.md" -IncludeWikiSummary $true -IncludeWikiTOC $true -WikiTOCStyle "Github"

    Write-Output ("Setting up Readme")
    $readmefile = (".\README.md")
    Write-Output ("Readme file: $($readmefile)")
    $scriptTOC = Get-Content $readmefile
    ("[![Build Status](https://dev.azure.com/familie-boers/Powershell/_apis/build/status/LeonB87.Powershell-Scripts?branchName=develop)](https://dev.azure.com/familie-boers/Powershell/_build/latest?definitionId=10&branchName=develop) `r`n") | Out-File $readmefile -Force
    ("# Powershell script report `r") | Out-File $readmefile -Append
    ("[Develop Report Script](https://pscodehealth.blob.core.windows.net/pscodehealthcontainer/develop-PSCodeHealthReport.html) `r`n")  | Out-File $readmefile -Append
    ("# Scripts `r") | Out-File $readmefile -Append
    ("Summary of scripts") | Out-File $readmefile -Append
    $scriptTOC | Out-File $readmefile -Append
}
END {
    Write-Host "## Ending the local run of the analyzer scripts!" -ForegroundColor DarkBlue
}