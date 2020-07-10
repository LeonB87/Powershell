Function Test-IPBlacklist () {
    #Requires -RunAsAdministrator
    <#
    .SYNOPSIS
    Check an IP-Addres if it's blacklisted

    .PARAMETER IP
    Supply the IP-Address if it's blacklisted

    .EXAMPLE
    Test-IPBlacklist 23.208.77.128

    This performs a blacklist check and returns True or False

    .EXAMPLE
    Test-IPBlacklist 23.208.77.128 -class Blacklistcheck -namespace Company

    This performs a blacklist check and returns True or False. This also stores the information in WMI. Specify a namespace and class where you would like to store the data
    use this to use other 3th party solutions to monitor the results.

    .COMPONENT
    General Functions.psm1

    .NOTES
    ===========================================================================
    Created by: Léon Boers
    Github: https://github.com/LeonB87/Scripts

    Versions:
    0.00 - 05-11-2018 - LBS - Initial Release
    0.00 - 18-11-2018 - LBS - Made storing the data to WMI optional
	===========================================================================
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Report'
    )]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ParameterSetName = "Report",
            HelpMessage = "Supply the IP-Addres you would like to check if it's blacklisted"
        )]
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ParameterSetName = "WMI",
            HelpMessage = "Supply the IP-Addres you would like to check if it's blacklisted"
        )]
        [String]$IP,
        [Parameter(Mandatory = $false,
            Position = 1,
            ValueFromPipeline = $false,
            ParameterSetName = "WMI",
            HelpMessage = "Specify the namespace to store the data in")]
        [ValidateNotNullOrEmpty()]
        [string]
        $namespace,
        [Parameter(Mandatory = $false,
            Position = 2,
            ValueFromPipeline = $false,
            ParameterSetName = "WMI",
            HelpMessage = "Specify the class to store the data in")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Class = "BlackListCheck"
    )

    BEGIN {
        Log-ScriptProgression -LogDirectory "\Logs\BlacklistCheck" -LogName BlackListCheck -LogRetentionDays 31
        [Datetime]$date = get-date
        $blacklisted = $false
        $list = "n.v.t."
    }
    PROCESS {

        # If company is not filled with data, This means were not going to Write to WMI and store the data. We'll just return the data
        if ($namespace) {
            #######################################################################################
            # WMI Part 1 - Preparation of WMI
            #######################################################################################
            # Check to see if the root\cimv2\%namespace% WMI namespace exists - if it doesn't, then let's create it
            # Thanks to http://gallery.technet.microsoft.com/scriptcenter/d230c216-9d21-4130-a190-4049ca2df21c for the code
            If (Get-WmiObject -Namespace "root\cimv2" -Class "__NAMESPACE" | Where-Object {$_.Name -eq $Namespace}) {
                WRITE-HOST "The root\cimv2\$($Namespace) WMI namespace exists."
            }
            Else {
                WRITE-HOST "The root\cimv2\$($Namespace) WMI namespace does not exist."
                $wmi = [wmiclass]"root\cimv2:__Namespace"
                $newNamespace = $wmi.createInstance()
                $newNamespace.name = $Namespace
                $newNamespace.put()
            }



            # Check to see if the class exists - if it doesn't, then let's create it
            # Check to see if the class exists - if it doesn't, then let's create it
            If (Get-WmiObject -List -Namespace "root\cimv2\$($Namespace)" | Where-Object {$_.Name -eq $Class}) {
                WRITE-HOST "The " $Class " WMI class exists."
                # Because the class already exists, we need to make sure it's 'blank', and does not contain any pre-populated instances
                # Hint: Pre-populated instances could have come from someone having already run this script.
                $GetExistingInstances = Get-WmiObject -Namespace "root\cimv2\$($Namespace)" -Class $Class
                If ($null -eq $GetExistingInstances) {
                    WRITE-HOST "There are no instances in this WMI class."
                }
                Else {

                }
            }
            WRITE-HOST "Now creating the " $Class " WMI class."
            # Because the class doesn't exist, let's create it, and specify all of the appropriate properties.
            $subClass = New-Object System.Management.ManagementClass ("root\cimv2\$($Namespace)", [String]::Empty, $null); 
            $subClass["__CLASS"] = $Class; 
            $subClass.Qualifiers.Add("Static", $true)
            $subClass.Properties.Add("IP", [System.Management.CimType]::String, $false)
            $subClass.Properties["IP"].Qualifiers.Add("Key", $true)
            $subClass.Properties.Add("LastChecked", [System.Management.CimType]::DateTime, $false)
            $subClass.Properties["LastChecked"].Qualifiers.Add("Key", $true)
            $subClass.Properties.Add("Blacklisted", [System.Management.CimType]::UInt8, $false)
            $subClass.Properties.Add("Blacklists", [System.Management.CimType]::String, $false)
            $subClass.Properties.Add("NumberOfBlacklists", [System.Management.CimType]::UInt8, $false)
            $subClass.Put()
        } #END IF (Company)
        else {
            write-output "Company variable is empty. we're not storing the found data to WMI."
        } #END ELSE (Company)

        #######################################################################################
        # Blacklist Part of the Script
        #######################################################################################
        $reversedIP = ($IP -split '\.')[3..0] -join '.'
        $blacklistServers = @(
            'b.barracudacentral.org'
            'spam.rbl.msrbl.net'
            'zen.spamhaus.org'
            'cbl.abuseat.org'
            'noptr.spamrats.com'
            'spam.spamrats.com'
            'dnsbl.sorbs.net'
            'problems.dnsbl.sorbs.net'
            'relays.dnsbl.sorbs.net'
            'http.dnsbl.sorbs.net'
            'smtp.dnsbl.sorbs.net'
            'new.spam.dnsbl.sorbs.net'
            'recent.spam.dnsbl.sorbs.net'
            'bl.spamcop.net'
            'free.v4bl.org'
            'list.quorum.to'
            'block.stopspam.org'
            'dnsbl.stopspam.org'
        )
        $blacklistedOn = @()

        foreach ($server in $blacklistServers) {
            $fqdn = "$reversedIP.$server"

            try {
                $null = [System.Net.Dns]::GetHostEntry($fqdn)
                $blacklistedOn += $server
            }
            catch { }
        }

        if ($blacklistedOn.Count -gt 0) {
            $list = $($blacklistedOn -join ', ')
            Write-output "$IP is blacklisted on the following servers: $list"
            $blacklisted = $true
        }
        else {
            Write-output "$IP is not currently blacklisted on any server."

            if ((Get-Date).Hour -eq 9) {
                # The IP was not blacklisted, but it's between 9:00 and 10:00 AM (local time); you can send your sanity email here
            }
        }
        $totalblacklists = ($blacklistedOn.Count)

        if ($company) {
            ##############################################
            # (RE)Place the data in WMI
            ##############################################
            #
            #

            $FilterURL = 'IP = "' + $IP + '"'
            write-host $FilterURL
            $mb = Get-WmiObject -Class $Class -Filter $FilterURL -Namespace root\cimv2\$Namespace
            $mb | Remove-WMIObject

            $PushDataToWMI = ([wmiclass]"root\cimv2\$($Namespace):$($Class)").CreateInstance()
            $PushDataToWMI.IP = $IP
            $PushDataToWMI.LastChecked = [Management.ManagementDateTimeConverter]::ToDMTFDateTime($date)
            $PushDataToWMI.Blacklisted = $blacklisted
            $PushDataToWMI.Blacklists = $list
            $PushDataToWMI.NumberOfBlacklists = $totalblacklists
            $PushDataToWMI.Put()
        }   # END IF (COMPANY)
    }
    END {
        return $blacklisted
        Stop-Transcript
    }

}