
function Get-RemoveUnwantedLanguagePack {
    param (
        [parameter(Mandatory = $true)]
        [String]
        $containerName
    )
    
    $apps = Get-BcContainerAppInfo -containerName $containerName | Select-Object name 

    $ignoreList = 'United States', 'Icelandic'

    foreach ( $tmp in $apps) {
        if ($ignoreList | ? { $tmp.Name.ToString() -notmatch $_ }) {
            if ('language' | ? { $tmp.Name.ToString() -match $_ }) {
                
                #Write-Output $tmp.Name.ToString()
                UnPublish-BcContainerApp -containerName $containerName -name $tmp.Name.ToString()
            }
        }
    }
}

