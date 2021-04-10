- [Synopsis](#synopsis)
- [Information](#information)
- [Description](#description)
- [Examples](#examples)
     * [Example 1](#example-1)
     * [Example 2](#example-2)
- [Parameters](#parameters)
     * [Path](#path)
     * [outputType](#outputtype)

## Synopsis

Script to create a Tree view of a folder

```PowerShell
 .\Get-FolderStructure.ps1 [-Path] <String> [[-outputType] <String>] [<CommonParameters>]
```

## Information

**Version:**         1.0.0

**Author:**          Léon Boers

**Creation Date:**   22-03-2020

**Purpose/Change:**  Initial script development



## Description

Script to create a Tree view of a folder. It recurses through the folder and will collect all folders and files.
It returns a Powershell Object by default and optionally Json


## Examples

### Example 1

```PowerShell
 .\Get-FolderStructure -Path "C:\MyFolder"
```

### Example 2

```PowerShell
 .\Get-FolderStructure -Path ".\" -outputType Json
```

## Parameters

### Path

the root path you want to create a treesize off
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 1|
| Required : | true|
### outputType

The defined output. This defaults to an Object.
Accepts the following input;  Object (default), Json
| | |
|-|-|
| Type: | String |
| DefaultValue : | Object|
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 2|
| Required : | false|
