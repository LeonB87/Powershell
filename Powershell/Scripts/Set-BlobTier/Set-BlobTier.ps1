$storageAccountName = ""     # Enter account name
$storageContainer = ""           # Enter specific container
$prefix = "a"                      # Set prefix for scanning
$MaxReturn = 10000
$count = 0
$StorageAccountKey = "" # Enter account/sas key

Write-Host "Starting script"

$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $StorageAccountKey 
$Token = $Null

do {  
    $listOfBlobs = Get-AzStorageBlob -Container $storageContainer -Context $ctx -MaxCount $MaxReturn -ContinuationToken $Token -Prefix $prefix
  
    foreach ($blob in $listOfBlobs) {  
        if ($blob.ICloudBlob.Properties.StandardBlobTier -eq "Archive") { 
            $blob.ICloudBlob.SetStandardBlobTier("Hot")
            #write-host "the blob " $blob.name " is being set to Hot"
            $count++
        }
    }  
    $Token = $blob[$blob.Count - 1].ContinuationToken;  
    
    Write-Host "Processed " ($count) " items. Continuation token = " $Token.NextMarker
}while ($Null -ne $Token)

Write-Host "Complete processing of all blobs returned with prefix " $prefix