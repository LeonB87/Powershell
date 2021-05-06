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
                [string]$dnsRecordType = "txt"
            )
            process {
                $params = @{
                    Type        = $dnsRecordType
                    Name        = $DomainName
                    ErrorAction = "Stop"
                }
                if ($Server) {
                    $params.Add("Server", $Server)
                }
                try {
                    $dns = Resolve-DnsName @params -ErrorAction SilentlyContinue

                    if ($filter) {
                        $dns = $dns | Where-Object Strings -Match $Filter
                    }

                    $returnObject = $dns | Select-Object @{Name = "DomainName"; Expression = { $_.Name } }, @{Name = "Record"; Expression = { $_.Strings } }
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
        #Get-DnsRecords -DomainName "familie-boers.nl" -Filter "spf1"

        # This returns the Dmarc record
        #Get-DnsRecords -DomainName "_dmarc.familie-boers.nl"

        # TODO: Get DKIM Records
        Get-DnsRecords -DomainName "selector1._domainkey.3fifty.eu" -dnsRecordType "cname"

        # TODO: Get Dkim settings
    }
    END {

    }
}

get-azuredomainsDmarc