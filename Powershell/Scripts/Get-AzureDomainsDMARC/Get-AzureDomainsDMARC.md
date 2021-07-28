- [Synopsis](#synopsis)
- [Information](#information)
- [Prerequisites](#prerequisites)
- [Description](#description)
- [Examples](#examples)
     * [Example 1](#example-1)
- [Parameters](#parameters)
     * [customDNS](#customdns)
     * [TenantId](#tenantid)

## Synopsis

collects tenant SPF,DMARC, DKIM records for all domains in an Azure Tenant.

```PowerShell
 .\Get-AzureDomainsDMARC.ps1 [[-customDNS] <String>] [-TenantId] <String> [<CommonParameters>]
```

## Information

**Version:**         1.0.0

**Author:**          Léon Boers

**Creation Date:**   10-05-2020

**Purpose/Change:**  Initial script development

**Credits:**         Initial script snippet for retrieving DNS record was originally from 'ntsystems.it' and altered by me

**Version 1.0.0:**   Initial setup of the script

## Prerequisites

| Module | Tested Version |
|-|-|
| Az.Accounts | 1.9.2 |


## Description

Connect to an Azure Tenant and collects all registered Domain names.
for each domain name, the current SPF, DMARC and DKIM Selector1 an 2 are retrieved.

The collected information is export as a CSV file in the folder you run the script.


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
