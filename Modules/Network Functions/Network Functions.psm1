
Function Collect-DNSRecords () {
[CmdletBinding()]

    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            HelpMessage = "DNS Name.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DNS,

        [Parameter(Mandatory = $true,
            Position = 1,
            HelpMessage = "The DNS Server to Use")]
        [string]
        $DNSServer = $env:COMPUTERNAME,

        [Parameter(Mandatory = $false,
            Position = 2,
            HelpMessage = "The Type of the DNS-Record")]
        [ValidateSet(
            "MX"
        )]
        [string]
        $Type = "MX"
    )


    BEGIN {

    }
    PROCESS {
        $DNSArray = @()
        $Record = New-Object PSObject

        switch ($Type) {
            "MX" { 
                $DNSResults = Resolve-DnsName $DNS -Type 15 -DnsOnly -Server $DNSServer

                foreach ($Result in $DNSResults) {
                    if ($Result.QueryType -eq "MX") {
                        $Record | Add-Member -type NoteProperty -Name 'Preference' -Value $result.Preference
                        $Record | Add-Member -type NoteProperty -Name 'NameExchange' -Value $Result.NameExchange
                        $Record | Add-Member -type NoteProperty -Name 'TTL' -Value $Result.TTL
                        $DNSArray += $Record
                        clear-variable Record
                    }
                }
            }
            Default {}
        }

    }
    END {
        write-output $DNSArray
    }
}