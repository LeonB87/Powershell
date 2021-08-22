[[_TOC_]]

## Synopsis

Returns the azure modules present in the web app

## Description

Returns the azure modules present in the web app including the powershell version running on the webapp.

```PowerShell
https://functionurl/api/List-Modules
```

## Information

**Version:**         1.0.0

**Author:**          Léon Boers

**Creation Date:**   09-08-2021

**1.0.0:**           Initial function development

## Prerequisites

| Module | Tested Version |
|-|-|

## function information


### Input


| | |
|-|-|
| authLevel: | anonymous |
| type: | httpTrigger |
| direction: | in |
| name: | Request |
| methods: | get |

### Json input Schema

**Bold** properties are required


#### Main input Schema


| Property | Type | Accepted values | Description |
|-|-|-|-|

### Json output Schema


| Property | Type | Description |
|-|-|-|
| count | integer |  |
| modules | object |  |
| PowershellVersion | string |  |

### Output example(s)

**Example 1**

```json
{
  "modules": {
    "managedModules": [
      {
        "Name": "Az.Accounts",
        "Version": "2.2.8",
        "Path": "C:\\home\\data\\ManagedDependencies\\210821134656478.r\\Az.Accounts\\2.2.8\\Az.Accounts.psd1"
      }
    ],
    "customModules": [
      {
        "Name": "custommodule",
        "Version": "1.0",
        "Path": "C:\\home\\site\\wwwroot\\Modules\\custommodule\\custommodule.psd1"
      }
    ],
    "defaultModules": [
      {
        "Name": "CimCmdlets",
        "Version": "7.0.0.0",
        "Path": "C:\\program files (x86)\\siteextensions\\functions\\3.1.3\\workers\\powershell\\7\\runtimes\\win\\lib\\netcoreapp3.1\\Modules\\CimCmdlets\\CimCmdlets.psd1"
      },
      {
        "Name": "Microsoft.PowerShell.Diagnostics",
        "Version": "7.0.0.0",
        "Path": "C:\\program files (x86)\\siteextensions\\functions\\3.1.3\\workers\\powershell\\7\\runtimes\\win\\lib\\netcoreapp3.1\\Modules\\Microsoft.PowerShell.Diagnostics\\Microsoft.PowerShell.Diagnostics.psd1"
      },
      {
        "Name": "Microsoft.PowerShell.Host",
        "Version": "7.0.0.0",
        "Path": "C:\\program files (x86)\\siteextensions\\functions\\3.1.3\\workers\\powershell\\7\\runtimes\\win\\lib\\netcoreapp3.1\\Modules\\Microsoft.PowerShell.Host\\Microsoft.PowerShell.Host.psd1"
      },
      {
        "Name": "Microsoft.PowerShell.Management",
        "Version": "7.0.0.0",
        "Path": "C:\\program files (x86)\\siteextensions\\functions\\3.1.3\\workers\\powershell\\7\\runtimes\\win\\lib\\netcoreapp3.1\\Modules\\Microsoft.PowerShell.Management\\Microsoft.PowerShell.Management.psd1"
      },
      {
        "Name": "Microsoft.PowerShell.Security",
        "Version": "7.0.0.0",
        "Path": "C:\\program files (x86)\\siteextensions\\functions\\3.1.3\\workers\\powershell\\7\\runtimes\\win\\lib\\netcoreapp3.1\\Modules\\Microsoft.PowerShell.Security\\Microsoft.PowerShell.Security.psd1"
      },
      {
        "Name": "Microsoft.PowerShell.Utility",
        "Version": "7.0.0.0",
        "Path": "C:\\program files (x86)\\siteextensions\\functions\\3.1.3\\workers\\powershell\\7\\runtimes\\win\\lib\\netcoreapp3.1\\Modules\\Microsoft.PowerShell.Utility\\Microsoft.PowerShell.Utility.psd1"
      },
      {
        "Name": "Microsoft.WSMan.Management",
        "Version": "7.0.0.0",
        "Path": "C:\\program files (x86)\\siteextensions\\functions\\3.1.3\\workers\\powershell\\7\\runtimes\\win\\lib\\netcoreapp3.1\\Modules\\Microsoft.WSMan.Management\\Microsoft.WSMan.Management.psd1"
      },
      {
        "Name": "PSDiagnostics",
        "Version": "7.0.0.0",
        "Path": "C:\\program files (x86)\\siteextensions\\functions\\3.1.3\\workers\\powershell\\7\\runtimes\\win\\lib\\netcoreapp3.1\\Modules\\PSDiagnostics\\PSDiagnostics.psd1"
      },
      {
        "Name": "Microsoft.Azure.Functions.PowerShellWorker",
        "Version": "0.3.0",
        "Path": "C:\\Program Files (x86)\\SiteExtensions\\Functions\\3.1.3\\workers\\powershell\\7\\Modules\\Microsoft.Azure.Functions.PowerShellWorker\\Microsoft.Azure.Functions.PowerShellWorker.psd1"
      },
      {
        "Name": "Microsoft.PowerShell.Archive",
        "Version": "1.2.5",
        "Path": "C:\\Program Files (x86)\\SiteExtensions\\Functions\\3.1.3\\workers\\powershell\\7\\Modules\\Microsoft.PowerShell.Archive\\1.2.5\\Microsoft.PowerShell.Archive.psd1"
      },
      {
        "Name": "Microsoft.PowerShell.Management",
        "Version": "7.0.0.0",
        "Path": "C:\\Program Files (x86)\\SiteExtensions\\Functions\\3.1.3\\workers\\powershell\\7\\Modules\\Microsoft.PowerShell.Management\\Microsoft.PowerShell.Management.psd1"
      },
      {
        "Name": "Microsoft.PowerShell.Utility",
        "Version": "7.0.0.0",
        "Path": "C:\\Program Files (x86)\\SiteExtensions\\Functions\\3.1.3\\workers\\powershell\\7\\Modules\\Microsoft.PowerShell.Utility\\Microsoft.PowerShell.Utility.psd1"
      },
      {
        "Name": "PackageManagement",
        "Version": "1.4.7",
        "Path": "C:\\Program Files (x86)\\SiteExtensions\\Functions\\3.1.3\\workers\\powershell\\7\\Modules\\PackageManagement\\1.4.7\\PackageManagement.psd1"
      },
      {
        "Name": "PowerShellGet",
        "Version": "2.2.5",
        "Path": "C:\\Program Files (x86)\\SiteExtensions\\Functions\\3.1.3\\workers\\powershell\\7\\Modules\\PowerShellGet\\2.2.5\\PowerShellGet.psd1"
      },
      {
        "Name": "ThreadJob",
        "Version": "2.0.3",
        "Path": "C:\\Program Files (x86)\\SiteExtensions\\Functions\\3.1.3\\workers\\powershell\\7\\Modules\\ThreadJob\\2.0.3\\ThreadJob.psd1"
      }
    ]
  },
  "PowershellVersion": "7.0",
  "count": 17
}
```

## Parameters

### -Request

This is a default parameter for Azure Powershell functions that holds the body of the request

| | |
|-|-|
| Type: | Object |
| ParameterValue : | Object|
| PipelineInput : | false|
| Position : | 1|
| Required : | false|

### -TriggerMetadata

This is a default parameter for Azure Powershell functions that holds additional information regarding the request.

| | |
|-|-|
| Type: | Object |
| ParameterValue : | Object|
| PipelineInput : | false|
| Position : | 2|
| Required : | false|
