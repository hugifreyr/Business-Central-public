


# BcContainerHelper is needed to use this function. See UpdateBcContainerHelper.ps1

function Get-BCDevInstallLicense () 
{
    #License files to use in if else statement below
    $BC14License = "E:\License\BC14.flf"
    $BC17License = "E:\License\BC17.flf"
    $BC18License = "E:\License\BC18.flf"
    $BC19License = "E:\License\BC19.flf"
    $BC20License = "E:\License\BC20.flf"
    $BC21License = "E:\License\BC21.flf"

    #Define name of containers that script should ignore
    $ignoreList = "magical_cannon", "portainer"

    $Containers = docker ps -a --format "{{.Names}}" --filter status=running 
    # TODO switch to Get-BcContainers

    foreach ( $tmp in $Containers) {
        if ( $ignoreList -inotcontains $tmp) {
            try {
                Write-Output $tmp
                $version = Get-BcContainerNavVersion -containerOrImageName $tmp
                Write-Output $version
                
                if ($version -like "14.*") {
                    Import-BcContainerLicense -containerName $tmp -licenseFile $BC14License  
                }
                elseif ($version -like "17.*") {
                    Import-BcContainerLicense -containerName $tmp -licenseFile $BC17License  
                }
                elseif ($version -like "18.*") {
                    Import-BcContainerLicense -containerName $tmp -licenseFile $BC18License  
                }
                elseif ($version -like "19.*") {
                    Import-BcContainerLicense -containerName $tmp -licenseFile $BC19License  
                }
                elseif ($version -like "20.*") {
                    Import-BcContainerLicense -containerName $tmp -licenseFile $BC20License  
                }
                elseif ($version -like "21.*") {
                    Import-BcContainerLicense -containerName $tmp -licenseFile $BC21License  
                }
                else {
                    Write-Output "Version not defined in script..."
                }
            }
            catch {
                Write-Output "Unable to get Container BC version for container $tmp"
            }
        }
        else {
            Write-Output "$tmp is on ignore list"
        }
    }
}