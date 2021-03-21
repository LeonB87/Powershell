# Table of Contents 
- [Synopsis](#synopsis) 
- [Information](#information) 
- [Examples](#examples) 
     * [Example 1](#example-1) 
- [Parameters](#parameters) 
     * [InputString](#inputstring) 

## Synopsis
Script to generate TOC strings that work on Github


```PowerShell
 .\Generate-githubTOC.ps1 [-InputString] <String> [<CommonParameters>]
```


## Information
**Version:**         1.0.0

**Author:**          Léon Boers

**Creation Date:**   20-03-2021

**Purpose/Change:**  Initial script development



## Description
Script to generate TOC strings that work on Github. It uses a single input string and converts it to a link that works on Github.
This script originated because I wanted an automated way to include an TOC that I've used on Azure DevOps. Unfortunately, [[_TOC_]] doesn't work on Github.


## Examples


###  Example 1 
```PowerShell
 Generate-GithubTOC -InputString '## header 2' 
```
## Parameters
### InputString
This is the input string that the script will convert. Must contains between 1 and 5 # characters.
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 1|
| Required : | true|


# Table of Contents 
- [Synopsis](#synopsis) 
- [Information](#information) 
- [Examples](#examples) 
     * [Example 1](#example-1) 
- [Parameters](#parameters) 
     * [InputString](#inputstring) 

