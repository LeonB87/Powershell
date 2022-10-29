

function Set-BlobTier {
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
        [string]$regularExpression = "^2019",

        [Parameter(Mandatory = $false)]
        [ValidateSet("Cold", "Hot", "Archive", "Any")]
        [string]$sourceTier = "*",

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
        Write-Output ("File with the source tier set to '$($sourceTier)' will be changed to '$($targetTier)'")
    }
    process {
        $storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $StorageAccountKey

        #TODO: Validate context

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

                if ($blob.Name -match $regularExpression) {
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
}

Set-BlobTier -regularExpression '^(202[0-1])|^201[0-9]' -storageAccountName 'azstorphotobackup' -storageContainer 'suzannefotografie' -StorageAccountKey $accessKey -sourceTier Any -targetTier Archive