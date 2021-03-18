

function CopyFilesToBCContainer()
{
    Param(
        $LocalPath = "C:\BC\XMLfiles\",
        $ContainerPath = "C:\Run\XMLfiles\",
        [parameter(Mandatory = $true)]
        $ContainerName  
    )

    $temp = Get-ChildItem -Path $LocalPath -Recurse 

    foreach ( $suffix in $temp ) {
        $name = $suffix.Name
        $file = "$LocalPath\$name"
        try {
                
                Copy-FileToBcContainer -containerName $ContainerName -localPath $file -containerPath "$ContainerPath\$name"
                Write-Output $file
        }
        finally {
        }
    }

}