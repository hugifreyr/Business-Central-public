

function CopyFilesToBCContainer()
{
    Param(
        $LocalPath = "C:\Users\hugife\Downloads\XMLfiles\",
        $ContainerPath = "C:\Run\XMLfiles\",
        [parameter(Mandatory = $true)]
        $ContainerName  
    )

    $temp = Get-ChildItem -Path $DownloadFolder -Recurse 

    foreach ( $suffix in $temp ) {
        $name = $suffix.Name
        $file = "$DownloadFolder\$name"
        try {
                
                Copy-FileToBcContainer -containerName $ContainerName -localPath $file -containerPath "$ContainerPath\$name"
                Write-Output $file
        }
        finally {
        }
    }

}