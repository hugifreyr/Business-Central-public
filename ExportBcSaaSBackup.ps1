Import-Module Az

#App and Tenant ID
$tenantName = "" #NEEDS TO BE UPDATED
$applicationId = "" #NEEDS TO BE UPDATED

#Authentication
$redirectUri = "http://localhost"
$authority = "https://login.microsoftonline.com/$tenantName"
$scopes = [String[]]@("https://api.businesscentral.dynamics.com/.default")
$client = [Microsoft.Identity.Client.PublicClientApplicationBuilder]::Create($applicationId).WithAuthority($authority).WithRedirectUri($redirectUri).Build()
$accessToken = $client.AcquireTokenInteractive($scopes).ExecuteAsync().GetAwaiter().GetResult().AccessToken


#https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/tenant-admin-center-database-export
#https://learn.microsoft.com/en-us/azure/storage/common/storage-sas-overview
    #"The SAS token requires 'Create', 'Delete', 'Read', and 'Write' permissions (sp=cdrw)"
#https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/administration-center-api

#From Azure Portal
$GlobalResourceGroupName = "" #NEEDS TO BE UPDATED
$GlobalStorageAccName = "" #NEEDS TO BE UPDATED
#Storage account -> SAS -> Blob service SAS URL
$GlobalSasUrl = "https://something.blob.core.windows.net/...." #NEEDS TO BE UPDATED
$GlobalBlobContainerName = "" #NEEDS TO BE UPDATED

#From BC admin center
$GlobalEnvironmentName = "" #NEEDS TO BE UPDATED

#Other
$GlobalGetDate = Get-Date -Format "ddMMyyyy"
$GlobalDestinationPath = "c:\users\$env:USERNAME\downloads"
$GlobalBlobFileName = "$GlobalBlobContainerName-$GlobalEnvironmentName-$GlobalGetDate.bacpac"

Invoke-WebRequest "https://raw.githubusercontent.com/hugifreyr/Business-Central-public/master/ExportBcSaaSBackupFunctions.ps1" -OutFile "$GlobalDestinationPath\ExportBcSaaSBackup.ps1" 
Import-Module "$GlobalDestinationPath\ExportBcSaaSBackup.ps1"

function Get-BCBackup
{

    Get-BcSaaSExportMetrics

    Get-BcSaaSExportEnvironment -blobName $GlobalBlobFileName -containerName $GlobalBlobContainerName -environmentName $GlobalEnvironmentName -sasUrl $GlobalSasUrl

    Get-BcSaaSExportHistory

    while( (Get-BlobFileReadyStatus -BlobFileName $GlobalBlobFileName -ResourceGroupName $GlobalResourceGroupName -StorageAccName $GlobalStorageAccName -BlobContainerName $GlobalBlobContainerName) -eq $false)
    {
        Write-Host "Sleep for 5 min" -ForegroundColor Yellow
        Start-Sleep 300
    }

    Get-BackupFileFromAzureStorage -BlobFileName $GlobalBlobFileName -ResourceGroupName $GlobalResourceGroupName -StorageAccName $GlobalStorageAccName -BlobContainerName $GlobalBlobContainerName -DestinationPath $GlobalDestinationPath
}   

