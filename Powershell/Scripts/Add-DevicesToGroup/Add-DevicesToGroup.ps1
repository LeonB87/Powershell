

function Add-DevicesToGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$path,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$delimiter = ",",

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$targetGroupObjectId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Guid]$TenantId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Guid[]]$exclusions
    )
    BEGIN {
        Write-Output ("Importing devices from the file '$($path)'")
        $devices = Get-Content -Path $path -Raw | ConvertFrom-Csv -Delimiter $delimiter
        Write-Output ("Received '$($devices.Count)' devices")

        if (((Get-AzTenant -ErrorAction SilentlyContinue).Id -ne $TenantId)) {
            Write-Output ("connecting to the correct Azure Tenant")
            Disconnect-AzAccount
            Connect-AzAccount -Tenant $TenantId -UseDeviceAuthentication
        }
        else {
            Write-Output ("allready connected to the correct Azure Tenant")
        }

    }
    PROCESS {

        :deviceloop foreach ($device in $devices) {
            Write-Verbose ("Processing machine '$($device.displayName)' with ID '$($device.id)'")
            $err = $null

            if ($device.id -in $exclusions) {
                Write-Output ("Device is excluded")
                continue deviceloop
            }

            Add-AzADGroupMember -TargetGroupObjectId $targetGroupObjectId -MemberObjectId $device.id -ErrorVariable err -ErrorAction SilentlyContinue #-WhatIf

            if ($null -ne $err) {
                Write-Output ("An issue occured adding the device '$($device.displayName)' to the group with the following error '$($err)'")
            }
        }
    }
    END {}
}

$exclusions = (
    '98836f2d-8021-489e-b104-99a64d956455'
)

Add-DevicesToGroup -path "C:\Users\LéonBoers\Downloads\MDM - Device - Corporate _2022-10-7.csv" -TenantId '' -targetGroupObjectId '05af6d3c-289a-4866-8563-8a9075acb61f' -exclusions $exclusions