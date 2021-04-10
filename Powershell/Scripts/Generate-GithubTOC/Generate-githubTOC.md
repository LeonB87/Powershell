- [Synopsis](#synopsis)
- [Information](#information)
- [Description](#description)
- [Examples](#examples)
     * [Example 1](#example-1)
- [Parameters](#parameters)
     * [Path](#path)

## Synopsis

Script to generate TOC that works on Github

```PowerShell
 .\Generate-githubTOC.ps1 [-Path] <String> [<CommonParameters>]
```

## Information

**Version:**         1.1.0

**Author:**          Léon Boers

**Creation Date:**   20-03-2021

**Purpose/Change:**  Initial script development

**Version:** 1.1.0



## Description

Script to generate TOC that work on Github. It reads a target Markdown file and convert the headers to a TOC with a link that works on Github.
This script originated because I wanted an automated way to include an TOC that I've used on Azure DevOps. Unfortunately, [[_TOC_]] doesn't work on Github.


## Examples

### Example 1

```PowerShell
 .\Generate-GithubTOC -Path '\scripts\MyMarkdown.md'
```

## Parameters

### Path

This is the Path to a Markdown file that you want to generate a TOC for. Must contains between 1 and 5 # characters.
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 1|
| Required : | true|
