

function Get-BlobFileReadyStatus {
    Param(
        [parameter(Mandatory = $true)]
        $BlobContainerName,
        [parameter(Mandatory = $true)]
        $StorageAccName,
        [parameter(Mandatory = $true)]
        $BlobFileName,
        [parameter(Mandatory = $true)]
        $ResourceGroupName
    )
    
    try {       
        $StorageAcc = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccName 
        $Ctx = $StorageAcc.Context
        $Blob = Get-AzStorageBlob -Container $BlobContainerName -Context $Ctx -Blob $BlobFileName -ErrorAction Stop 
        $Mb = [int]($Blob.Length / 1024 / 1024)
        Write-Host "$BlobFileName found, size $Mb MB. Backup stored and ready in Azure Storage" -ForegroundColor Green
        return $true
    }
    catch [Microsoft.WindowsAzure.Commands.Storage.Common.ResourceNotFoundException] {
        # Add logic here to remember that the blob doesn't exist...
        Write-Host "Blob file $BlobFileName not ready..." -ForegroundColor Yellow
        return $false
    }
    catch {
        # Report any other error
        Write-Error $Error[0].Exception;
        return $false
    }
}


function Get-BcSaaSExportMetrics {
    Write-Host "Getting export metrics, specifically how many times can you export" -ForegroundColor Green
    $response = Invoke-WebRequest `
        -Method Get `
        -Uri    "https://api.businesscentral.dynamics.com/admin/v2.18/exports/applications/businesscentral/environments/$GlobalEnvironmentName/metrics" `
        -Headers @{Authorization = ("Bearer $accessToken") }
    Write-Host (ConvertTo-Json (ConvertFrom-Json $response.Content))
}

function Get-BcSaaSExportHistory {
    Param(
        [DateTime]
        $startTime = (Get-Date).AddDays(-1).tostring('s'),
        [DateTime]
        $endTime = (Get-Date).AddDays(1).tostring('s')
    )
    Write-Host "Getting Export History" -ForegroundColor Green
    $response = Invoke-WebRequest `
        -Method Get `
        -Uri    "https://api.businesscentral.dynamics.com/admin/v2.18/exports/history?start=$startTime&end=$endTime" `
        -Headers @{Authorization = ("Bearer $accessToken") }
    Write-Host (ConvertTo-Json (ConvertFrom-Json $response.Content)) 
}


function Get-BackupFileFromAzureStorage {
    Param(
        [parameter(Mandatory = $true)]
        $BlobContainerName,
        [parameter(Mandatory = $true)]
        $StorageAccName,
        [parameter(Mandatory = $true)]
        $BlobFileName,
        [parameter(Mandatory = $true)]
        $DestinationPath,
        [parameter(Mandatory = $true)]
        $ResourceGroupName
    )

    try {       
        $StorageAcc = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccName 
        $Ctx = $StorageAcc.Context
        Get-AzStorageBlobContent -Container $BlobContainerName -Blob $BlobFileName -Destination $DestinationPath -Force -Context $Ctx 
        Write-Host "$BlobFileName file downloaded to $DestinationPath" -ForegroundColor Green
        return $true
    }
    catch [Microsoft.WindowsAzure.Commands.Storage.Common.ResourceNotFoundException] {
        # Add logic here to remember that the blob doesn't exist...
        Write-Host "Unable to download Blob file $BlobFileName..." -ForegroundColor Red
        return $false
    }
    catch {
        # Report any other error
        Write-Error $Error[0].Exception;
        return $false
    }

}


function Get-BcSaaSExportEnvironment {
    Param(
        [parameter(Mandatory = $true)]
        $sasUrl,
        [parameter(Mandatory = $true)]
        $containerName,
        [parameter(Mandatory = $true)]
        $blobName, 
        [parameter(Mandatory = $true)]
        $environmentName
    )

    $blobName = $GlobalBlobFileName 
    $containerName = $GlobalBlobContainerName 
    $environmentName = $GlobalEnvironmentName 
    $sasUrl = $GlobalSasUrl

    # Export environment to a .bacpac file in a storage account
    $response = Invoke-WebRequest `
        -Method Post `
        -Uri    "https://api.businesscentral.dynamics.com/admin/v2.18/exports/applications/businesscentral/environments/$environmentName" `
        -Body   (@{
            storageAccountSasUri = $sasUrl
            container            = $containerName
            blob                 = $blobName
        } | ConvertTo-Json) `
        -Headers @{Authorization = ("Bearer $accessToken") } `
        -ContentType "application/json"
    Write-Host "Responded with: $($response.StatusCode) $($response.StatusDescription)"

}