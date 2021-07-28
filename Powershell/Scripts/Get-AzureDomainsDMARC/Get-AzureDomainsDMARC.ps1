<#
    .SYNOPSIS
    collects tenant SPF,DMARC, DKIM records for all domains in an Azure Tenant.

    .DESCRIPTION
    Connect to an Azure Tenant and collects all registered Domain names.
    for each domain name, the current SPF, DMARC and DKIM Selector1 an 2 are retrieved.

    The collected information is export as a CSV file in the folder you run the script.
    .PARAMETER customDNS
    (optional) Specify the ipv4 address of a custom DNS server.

    .PARAMETER TenantId
    The tenand ID you and to connect to and retrieve the domains.

    .EXAMPLE
    .\get-azuredomainsDmarc -TenantId "86ce8023-5427-4dd1-89a9-42f91996385d" -customDNS 8.8.8.8

    .NOTES
    Version:        1.0.0;
    Author:         Léon Boers;
    Creation Date:  10-05-2020;
    Purpose/Change: Initial script development;
    Credits:        Initial script snippet for retrieving DNS record was originally from 'ntsystems.it' and altered by me;
    Version 1.0.0:  Initial setup of the script;

    .COMPONENT
    Module:Tested Version;
    Az.Accounts:1.9.2;


    #>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidatePattern('^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$')]
    [string]$customDNS,

    [Parameter(Mandatory = $true)]
    [string]$TenantId

)
BEGIN {
    function Get-DnsRecords {
        <#
            .Synopsis
            Get DNS Record for a domain.
            .DESCRIPTION
            This function uses Resolve-DNSName to get the SPF Record for a given domain. Objects with a DomainName property,
            .EXAMPLE
            This example gets DNS records

            Inital script for DNS records is from https://ntsystems.it/PowerShell/TAK/Get-SPFRecord/
            #>
        [CmdletBinding()]
        param (
            # Specify the Domain name for the query.
            [Parameter(Mandatory = $true)]
            [string]$DomainName,

            # Specify a custo DNS server.
            [string]$Server,

            # Specify a filter for the records.
            [string]$Filter,

            # Record Type
            [string]$dnsRecordType = "txt",

            #Value Field
            [string]$valueField = "Strings"
        )
        process {
            $params = @{
                Type        = $dnsRecordType
                Name        = $DomainName
                ErrorAction = "SilentlyContinue"
            }
            if ($Server) {
                $params.Add("Server", $Server)
            }
            try {
                $dns = Resolve-DnsName @params

                if ($filter) {
                    $dns = $dns | Where-Object Strings -Match $Filter
                }

                $returnObject = $dns | Select-Object @{Name = "DomainName"; Expression = { $_.Name } }, @{Name = "Record"; Expression = { $_.$valueField } }
            }
            catch {
                Write-Warning $_
            }

            return $returnObject
        }
    } # END function Get-DnsRecords

    if (((Get-AzTenant -ErrorAction SilentlyContinue).Id -ne $TenantId)) {
        Disconnect-AzAccount
        Connect-AzAccount -Tenant $TenantId -UseDeviceAuthentication
    }

    $exportFileName = (".\AAD-Domains-$((Get-Date -Format "dd-MM-yyyy-HH-mm")).csv")
}
Process {

    $domains = @()
    $registeredDomains = (Get-AzTenant).Domains


    foreach ($domainName in $registeredDomains) {
        # This returns the SPF Record
        $param = @{
            DomainName = $($domainName)
            Filter     = "spf1"
        }
        $null -ne $CustomDNS ? ($param += @{Server = $customDNS}) : $null | Out-Null
        $spfRecord = Get-DnsRecords @param

        # This returns the Dmarc record
        $param = @{
            DomainName = ("_dmarc.$($domainName)")
        }
        $null -ne $CustomDNS ? ($param += @{Server = $customDNS}) : $null | Out-Null
        $dmarcRecord = Get-DnsRecords @param

        # This returns Selector1
        $param = @{
            DomainName    = ("selector1._domainkey.$($domainName)")
            dnsRecordType = "cname"
            valueField    = "NameHost"
        }
        $null -ne $CustomDNS ? ($param += @{Server = $customDNS}) : $null | Out-Null
        $selector1Record = Get-DnsRecords @param

        # This returns Selector1
        $param = @{
            DomainName    = ("selector2._domainkey.$($domainName)")
            dnsRecordType = "cname"
            valueField    = "NameHost"
        }
        $null -ne $CustomDNS ? ($param += @{Server = $customDNS}) : $null | Out-Null
        $selector2Record = Get-DnsRecords @param

        $domains += [PSCustomObject]@{
            DomainName = $domainName
            SPF        = $spfRecord.Record
            DMARC      = $dmarcRecord.Record
            Selector1  = $selector1Record.Record
            Selector2  = $selector2Record.Record
        }
    }
}
END {
    $domains | Export-Csv $exportFileName -Force -Delimiter ";" -NoClobber -Encoding utf8
}