
<#
    .SYNOPSIS
    Set blobs inside a specific container to a tier.

    .DESCRIPTION
    Set blobs inside a specific container to a tier by using a regular expression as filter.

    .PARAMETER storageAccountName
    the target storageaccount

    .PARAMETER storageContainer
    the target container

    .PARAMETER MaxReturn
    The maximum return items per call.

    .PARAMETER StorageAccountKey
    the storage account key

    .PARAMETER regularExpression
    (Optional) A regular Expression that has to match the files.

    .PARAMETER sourceTier
    The source tier of blobs to update. When set to "Any" will update all blobs

    .PARAMETER targetTier
    the tier to change a blob to

    .EXAMPLE
    .\Set-BlobTier -regularExpression '^(202[0-1])|^201[0-9]' -storageAccountName 'myaccountName' -storageContainer 'yearlyReports' -StorageAccountKey 'MySecretKEy' -sourceTier Any -targetTier Archive

    .NOTES
    Version:        1.0.0;
    Author:         Léon Boers;
    Creation Date:  30-10-2022;
    Purpose/Change: Initial script development;
    #>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [string]$storageAccountName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [string]$storageContainer,

    [Parameter(Mandatory = $false)]
    [ValidateNotNull()]
    [int]$MaxReturn = 10000,

    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [string]$StorageAccountKey,

    [Parameter(Mandatory = $false)]
    [ValidateNotNull()]
    [string]$regularExpression,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Cold", "Hot", "Archive", "Any")]
    [string]$sourceTier = "Any",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Cold", "Hot", "Archive")]
    [string]$targetTier = "Cold"
)
begin {

    if ($sourceTier -eq $targetTier) {
        Write-Error ("Sourcetier and target Tier are the same..")
        Exit 1
    }

    Write-Output ("Starting script")
    Write-Output ("Searching container '$($storageContainer)' in storage account '$($storageAccountName)' with regularExpression '$($regularExpression)'")
    Write-Output ("File(s) with the source tier set to '$($sourceTier)' will be changed to '$($targetTier)'")
}
process {
    $storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $StorageAccountKey

    if ($null -eq $storageContext) {
        Write-Error ("Unable to connect to the storage account. please check your settings.")
        Exit 1
    }

    if ([string]::IsNullOrWhiteSpace($regularExpression)) {
        Write-Verbose ("No regular expression was supplied.")
        $useRegex = $false
    }
    else {
        Write-Verbose ("No regular expression was supplied.")
        $useRegex = $true
    }

    $Token = $Null

    do {
        $blobs = Get-AzStorageBlob -Container $storageContainer -Context $storageContext -MaxCount $MaxReturn -ContinuationToken $Token

        :blobLoop foreach ($blob in $blobs) {
            if ($sourceTier -ne "Any") {
                if ($blob.ICloudBlob.Properties.StandardBlobTier -ine $sourceTier) {
                    Write-Verbose ("The blob '$($blob.Name)' has the wrong source Tier")
                    continue blobLoop
                }
            }

            if ($blob.ICloudBlob.Properties.StandardBlobTier -ieq $targetTier) {
                Write-Verbose ("The blob '$($blob.Name)' is already set to the tier '$($targetTier)'")
                continue blobLoop
            }

            if (($blob.Name -match $regularExpression) -or ($useRegex -eq $false)) {
                Write-Verbose ("Setting blob'$($blob.Name)' to '$($targetTier)'")
                $blob.ICloudBlob.SetStandardBlobTier($targetTier)
                $count++ | Out-Null
            }
            else {
                Write-Verbose ("The file '$blob.Name' does not match the regular expression '$($regularExpression)'")
                [int]$skipped++ | Out-Null
            }

        }
        $Token = $blob[$blob.Count - 1].ContinuationToken;

        Write-Output "Processed "($count)" items. Continuation token = " $Token.NextMarker
    }while ($Null -ne $Token)
}

end {
    Write-Output ("Converted '$($count)' files to Archive and skipped '$($skipped)'")
}