- [Synopsis](#synopsis)
- [Information](#information)
- [Description](#description)
- [Examples](#examples)
     * [Example 1](#example-1)
- [Parameters](#parameters)
     * [vwanResourcegroup](#vwanresourcegroup)
     * [virtualHubName](#virtualhubname)
     * [vnetResourcegroup](#vnetresourcegroup)
     * [virtualNetworkName](#virtualnetworkname)
     * [hubVnetConnectioName](#hubvnetconnectioname)
     * [associoatedRouteTable](#associoatedroutetable)
     * [propagatedRouteTable](#propagatedroutetable)
     * [propagatedLabels](#propagatedlabels)
## Synopsis

Setup a connection from the VWAN Hub to a VNET

```PowerShell
 .\Set-VhubtoVnetConnection.ps1 [-vwanResourcegroup] <String> [-virtualHubName] <String> [-vnetResourcegroup] <String> [-virtualNetworkName] <String> [-hubVnetConnectioName] <String> [[-associoatedRouteTable] <String>] [[-propagatedRouteTable] <String[]>] [[-propagatedLabels] <String[]>] [<CommonParameters>]
```

## Information

**Version:**         1.0.0

**Author:**          Léon Boers

**Creation Date:**   03-11-2022

**Purpose/Change:**  Initial script development



## Description

Does not
- does not work cross subscription


## Examples

### Example 1

```PowerShell
 $parameters = @{
        vwanResourcegroup     = "rg-vwan"
        vnetResourcegroup     = "rg-vnet"
        virtualHubName        = "vwan-001"
        virtualNetworkName    = "vnet001"
        hubVnetConnectioName  = "vwan-001-to-vnet001"
        associoatedRouteTable = "Default"
        propagatedRouteTable  = "None"
        propagatedLabels      = "None"
        vwanSubscriptionId    = "69427cbe-a3a3-41d4-ab48-cc6f350eef45"
        vnetSubscriptionId    = "f836b99a-c238-4e76-a1ef-0364231707cc"
}
```

## Parameters

### vwanResourcegroup

the resourcegroup name of the VWAN resource
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 1|
| Required : | true|
### virtualHubName

The name of the virtual hub where to setup the connection
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 2|
| Required : | true|
### vnetResourcegroup

the resourcegroup name of the vnet
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 3|
| Required : | true|
### virtualNetworkName

The name of the virtual network
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 4|
| Required : | true|
### hubVnetConnectioName

the hub to vnet connection name
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 5|
| Required : | true|
### associoatedRouteTable

the associated route table; defaults to default
| | |
|-|-|
| Type: | String |
| ParameterValue : | String|
| PipelineInput : | false|
| Position : | 6|
| Required : | false|
### propagatedRouteTable

the propagates route tables; defaults to none
| | |
|-|-|
| Type: | String[] |
| ParameterValue : | String[]|
| PipelineInput : | false|
| Position : | 7|
| Required : | false|
### propagatedLabels

the propagates route labels; defaults to none
| | |
|-|-|
| Type: | String[] |
| ParameterValue : | String[]|
| PipelineInput : | false|
| Position : | 8|
| Required : | false|
