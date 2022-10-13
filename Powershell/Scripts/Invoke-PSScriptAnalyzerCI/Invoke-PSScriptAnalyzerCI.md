- [Synopsis](#synopsis)
- [Information](#information)
- [Description](#description)
- [Examples](#examples)
     * [Example 1](#example-1)
- [Parameters](#parameters)
     * [path](#path)
## Synopsis

This scripts helps validating your powershell scripts in a CI pipeline

```PowerShell
 .\invoke-psscriptanalyzerCI.ps1 [-path] <String> [<CommonParameters>]
```

## Information

**Version:**         1.0.0

**Author:**          Léon Boers

**Creation Date:**   11-10-2022

**Purpose/Change:**  Initial script development



## Description

This scripts helps validating your powershell scripts in a CI pipeline. enter a path to the folder containing your .PS1 files
When errors or warnings are found, a write-errors/warning is outputted.


## Examples

### Example 1

```PowerShell
 Invoke-PSScriptAnalyzerCI -path C:\src\myPowershellScripts
```

## Parameters

### path

The path of the scripts. This folder and subfolders are searched with the filter *.ps1
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 1|
| Required : | true|
