
function Get-RemoveUnwantedLanguagePack {
    param (
        [parameter(Mandatory = $true)]
        [String]
        $containerName
    )
    
    $apps = Get-BcContainerAppInfo -containerName $containerName | Select-Object name | Sort-Object name

    $ignoreList = 'English language (United States)', 'Icelandic language (Iceland)'

    foreach ( $tmp in $apps) {
        $appName = $tmp.Name.ToString()

        if ($ignoreList -inotcontains $appName ) {
            if ('language' | Where-Object { $appName -match $_ }) {
                #Write-Output $tmp.Name.ToString()
                UnPublish-BcContainerApp -containerName $containerName -name $tmp.Name.ToString()
            }
        }
        
    }
}


