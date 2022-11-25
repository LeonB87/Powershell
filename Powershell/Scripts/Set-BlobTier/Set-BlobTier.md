- [Synopsis](#synopsis)
- [Information](#information)
- [Description](#description)
- [Examples](#examples)
     * [Example 1](#example-1)
- [Parameters](#parameters)
     * [storageAccountName](#storageaccountname)
     * [storageContainer](#storagecontainer)
     * [MaxReturn](#maxreturn)
     * [StorageAccountKey](#storageaccountkey)
     * [regularExpression](#regularexpression)
     * [sourceTier](#sourcetier)
     * [targetTier](#targettier)
## Synopsis

Set blobs inside a specific container to a tier.

```PowerShell
 .\Set-BlobTier.ps1 [-storageAccountName] <String> [-storageContainer] <String> [[-MaxReturn] <Int32>] [-StorageAccountKey] <String> [[-regularExpression] <String>] [[-sourceTier] <String>] [[-targetTier] <String>] [<CommonParameters>]
```

## Information

**Version:**         1.0.0

**Author:**          Léon Boers

**Creation Date:**   30-10-2022

**Purpose/Change:**  Initial script development



## Description

Set blobs inside a specific container to a tier by using a regular expression as filter.


## Examples

### Example 1

```PowerShell
 .\Set-BlobTier -regularExpression '^(202[0-1])|^201[0-9]' -storageAccountName 'myaccountName' -storageContainer 'yearlyReports' -StorageAccountKey 'MySecretKEy' -sourceTier Any -targetTier Archive
```

## Parameters

### storageAccountName

the target storageaccount
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 1|
| Required : | true|
### storageContainer

the target container
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 2|
| Required : | true|
### MaxReturn

The maximum return items per call.
| | |
|-|-|
| Type: | Int32 |
| DefaultValue : | 10000|
| ParameterValue : | Int32|
| PipelineInput : | false|
| Position : | 3|
| Required : | false|
### StorageAccountKey

the storage account key
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 4|
| Required : | true|
### regularExpression

(Optional) A regular Expression that has to match the files.
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 5|
| Required : | false|
### sourceTier

The source tier of blobs to update. When set to "Any" will update all blobs
| | |
|-|-|
| Type: | String |
| DefaultValue : | Any|
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 6|
| Required : | false|
### targetTier

the tier to change a blob to
| | |
|-|-|
| Type: | String |
| DefaultValue : | Cool|
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 7|
| Required : | false|
