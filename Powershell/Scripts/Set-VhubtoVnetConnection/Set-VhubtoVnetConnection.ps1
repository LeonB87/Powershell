<#
    .SYNOPSIS
    Setup a connection from the VWAN Hub to a VNET

    .DESCRIPTION

    Setup a connection from the VWAN Hub to a VNET

    .PARAMETER vwanResourcegroup
    the resourcegroup name of the VWAN resource

    .PARAMETER virtualHubName
    The name of the virtual hub where to setup the connection

    .PARAMETER vnetResourcegroup
    the resourcegroup name of the vnet

    .PARAMETER virtualNetworkName
    The name of the virtual network

    .PARAMETER hubVnetConnectioName
    the hub to vnet connection name

    .PARAMETER associoatedRouteTable
    the associated route table; defaults to default

    .PARAMETER propagatedRouteTable
    the propagates route tables; defaults to none

    .PARAMETER propagatedLabels
    the propagates route labels; defaults to none

    .PARAMETER vnetSubscriptionId
    The subscription ID of the target virtual network

    .PARAMETER vwanSubscriptionId
    The subscription ID of the target virtual wan

    .EXAMPLE
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
    Set-VhubtoVnetConnection @parameters

    .NOTES
    Version:        1.0.0;
    Author:         Léon Boers;
    Creation Date:  03-11-2022;
    Purpose/Change: Initial script development;

    #>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$vwanResourcegroup,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$virtualHubName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$vnetResourcegroup,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$virtualNetworkName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$hubVnetConnectioName,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$associoatedRouteTable = "default",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string[]]$propagatedRouteTable = "none",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string[]]$propagatedLabels = "none",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$vnetSubscriptionId,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$vwanSubscriptionId

)
begin {
    Write-Output ("Received the following inputs")
    Write-Output ("vwanResourcegroup:       $($vwanResourcegroup)")
    Write-Output ("vnetResourcegroup:       $($vnetResourcegroup)")
    Write-Output ("virtualHubName:          $($virtualHubName)")
    Write-Output ("virtualNetworkName:      $($virtualNetworkName)")
    Write-Output ("hubVnetConnectioName:    $($hubVnetConnectioName)")
    Write-Output ("associoatedRouteTable:   $($associoatedRouteTable)")
    Write-Output ("propagetadRouteTable:    $($propagatedRouteTable)")
    Write-Output ("propagatedLabels:        $($propagatedLabels)")
    Write-Output ("vnetSubscriptionId:      $($vnetSubscriptionId)")
    Write-Output ("vwanSubscriptionId:      $($vwanSubscriptionId)")

    $associoatedRouteTable = ($associoatedRouteTable -eq "Default") ? "defaultRouteTable" : $associoatedRouteTable
    $associoatedRouteTable = ($associoatedRouteTable -eq "None") ? "noneRouteTable" : $associoatedRouteTable

    foreach ($rt in $propagatedRouteTable) {
        $updatedName = ($rt -eq "Default") ? "defaultRouteTable" : $rt
        $updatedName = ($rt -eq "None") ? "noneRouteTable" : $rt
        $propagatedRouteTable = $propagatedRouteTable.Replace($rt, $updatedName)
    }

    Write-Output ("Switching to VNET context")
    Set-AzContext -SubscriptionId $vnetSubscriptionId
    $vnetRG = Get-AzResourceGroup -ResourceGroupName $vnetResourcegroup
    if ($null -eq $vnetRG) {
        Write-Error ("The VNET resourcegroup '$($vnetResourcegroup)' could not be found") ; Exit 1
    }

    $remoteVirtualNetwork = Get-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $vnetRG.ResourceGroupName
    if ($null -eq $remoteVirtualNetwork) {
        Write-Error ("The VNET'$($virtualNetworkName)' could not be found") ; Exit 1
    }

    Write-Output ("Switching to VWAN context")
    Set-AzContext -SubscriptionId $vwanSubscriptionId
    $vwanRG = Get-AzResourceGroup -ResourceGroupName $vwanResourcegroup
    if ($null -eq $vwanRG) {
        Write-Error ("The VWAN resourcegroup '$($vwanResourcegroup)' could not be found") ; Exit 1
    }

    $virtualHub = Get-AzVirtualHub -ResourceGroupName $vwanRG.ResourceGroupName -Name $virtualHubName
    if ($null -eq $virtualHub) {
        Write-Error ("The Virtual hub '$($virtualHubName)' could not be found") ; Exit 1
    }

}
process {
    $parameters = @{
        ParentObject = $virtualHub
        Name         = $hubVnetConnectioName
    }

    $HubVnetconnection = Get-AzVirtualHubVnetConnection @parameters -ErrorAction SilentlyContinue

    if ($null -ne $HubVnetconnection) {
        Write-Output ("The Hub To VNET connection with the name '$($hubVnetConnectioName)' is already present and has a provisioning state of '$($hubVnetConnection.ProvisioningState)'")
        Exit 0
    }

    if (-not [string]::IsNullOrWhiteSpace($propagatedRouteTable)) {
        Write-Output "'$($propagatedRouteTable.count)' Route Tables were supplied. Finding existing route tables"
        $routeTables = @{}
        foreach ($routeTableName in $propagatedRouteTable) {
            $rt = Get-AzVHubRouteTable -VirtualHub $virtualHub -Name $routeTableName
            if ($null -eq $rt) {
                Write-Error ("The route table with the name '$($routeTableName)' could not be found") ; Exit 1
            }
            else {
                $routeTables.add($routeTableName,$rt.Id)
            }
        }

        $rt = Get-AzVHubRouteTable -VirtualHub $virtualHub -Name $associoatedRouteTable
        $routeTables.add($associoatedRouteTable,$rt.Id)

        Write-Output ("Completed retrieving all route tables. Creating new Routing Configuration")
        if ($propagatedRouteTable.count -ge 1) {
            Write-Output ("Creating string[] of progagated route Tables")
            [string[]]$IDs = @()
            foreach ($routeTableName in $propagatedRouteTable) {
                $IDs += $routeTables[$routeTableName]
            }
        }

        $routeConfigParameters = @{
            Id                   = $IDs
            Label                = $propagatedLabels
            AssociatedRouteTable = $routeTables[$associoatedRouteTable]
        }

        $routeConfig = New-AzRoutingConfiguration @routeConfigParameters
        $parameters.add("RoutingConfiguration",$routeConfig)
    }
    else {
        Write-Output ("No routes were supplied.")
    }

    $parameters.add("RemoteVirtualNetwork",$remoteVirtualNetwork)

    $newRouting = New-AzVirtualHubVnetConnection @parameters

    if ($newRouting.ProvisioningState -eq "Succeeded") {
        Write-Output ("New AZ Hub to VNET connection established.")
    }
    else {
        Write-Error ("Something went wrong creating the connection.")
    }
}
end {

}