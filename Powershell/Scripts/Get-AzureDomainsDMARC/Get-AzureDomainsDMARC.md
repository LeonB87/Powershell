- [Synopsis](#synopsis)
- [Information](#information)
- [Description](#description)
- [Examples](#examples)
     * [Example 1](#example-1)
- [Parameters](#parameters)
     * [customDNS](#customdns)
     * [TenantId](#tenantid)

## Synopsis

collets tenant SPF,DMARC, DKIM records.

```PowerShell
 .\Get-AzureDomainsDMARC.ps1 [[-customDNS] <String>] [-TenantId] <String> [<CommonParameters>]
```

## Information

**Version:**         1.0.0

**Author:**          Léon Boers

**Creation Date:**   10-05-2020

**Purpose/Change:**  Initial script development

**require -Modules @{ ModuleName="Az.Accounts":** 

**ModuleVersion="1.9.2" }:** 



## Description

Connect to an Azure Tenant and collects all registered Domain names. for eah domain name, the current SPF, DMARC en DKIM Selector1 an 2 are retrieved.


## Examples

### Example 1

```PowerShell
 .\get-azuredomainsDmarc -TenantId "86ce8023-5427-4dd1-89a9-42f91996385d" -customDNS 8.8.8.8
```

## Parameters

### customDNS

(optional) Specify the ipv4 address of a custom DNS server.
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 1|
| Required : | false|
### TenantId

The tenand ID you and to connect to and retrieve the domains.
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 2|
| Required : | true|
