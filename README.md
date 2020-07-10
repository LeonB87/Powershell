[![Build Status](https://dev.azure.com/familie-boers/Powershell/_apis/build/status/LeonB87.Powershell-Scripts?branchName=develop)](https://dev.azure.com/familie-boers/Powershell/_build/latest?definitionId=10&branchName=master)

# Scripts

PowerShell Scripts and Modules I created myself or found online and edited to my liking.
Please read the header descriptions and comments in each script body, some contain important instructions or warnings.

## General Functions.psm1

Collection of several functions I reuse throughout my scripts. Be sure this is loaded before running other script that depend on them.

Method 1 : Import-Module %Full Path to .psm1 File%

Method 2 : Place the .psm1 file in any of the default PowerShell Module folder. To get a list of valid folders, type $env:PSModulePath in PowerShell.

Some of the defaults:

- C:\Users\%username%\Documents\WindowsPowerShell\Modules
- C:\Program Files\WindowsPowerShell\Modules

The Windows Default location for script is located at

- C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules

Windows recommends not to install scripts there.

## Disclaimer

Use the scripts and modules that are provided here at your own risk. Make sure you understand what the scripts do and could cause if not used properly