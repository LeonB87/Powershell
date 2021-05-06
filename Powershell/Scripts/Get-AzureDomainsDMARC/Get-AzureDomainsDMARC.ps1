function get-azuredomainsDmarc {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [bool]$GetSPF = $true,

        [Parameter(Mandatory = $false)]
        [bool]$GetDMARC = $true,

        [Parameter(Mandatory = $false)]
        [string]$customDNS,

        [Parameter(Mandatory = $false)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$domainName
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
            #>
            [CmdletBinding(HelpUri = 'https://ntsystems.it/PowerShell/TAK/Get-SPFRecord/')]
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
    }
    Process {
        # This returns the SPF Record
        Get-DnsRecords -DomainName $($domainName) -Filter "spf1"

        # This returns the Dmarc record
        Get-DnsRecords -DomainName ("_dmarc.$($domainName)")

        # This returns Selector1
        Get-DnsRecords -DomainName ("selector1._domainkey.$($domainName)") -dnsRecordType "cname" -valueField "NameHost"

        # This returns Selector1
        Get-DnsRecords -DomainName ("selector2._domainkey.$($domainName)") -dnsRecordType "cname" -valueField "NameHost"

    }
    END {

    }
}

get-azuredomainsDmarc -domainName "3fifty.eu"

get-azuredomainsDmarc -domainName "westerdijkstraat.nl"