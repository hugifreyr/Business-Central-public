
# BCContainerHelper release notes
# https://github.com/microsoft/navcontainerhelper/blob/master/ReleaseNotes.txt

function Get-UpdateBcContainerHelper() {   
    Param(
        $ModuleName = "bccontainerhelper",
        $ModulePath = "C:\Program Files\WindowsPowerShell\Modules",  
        [Switch]$AllowPrerelease
    )

    try {
        #What version is installed.
        Write-Output "Get-InstalledModule $ModuleName ..."
        Get-InstalledModule $ModuleName | Select-Object Name, Version 

        try {
            #Show module subfolders. Only one folder should be listed
            Write-Output "`nShow module subfolders. Only one folder should be listed..."
            Write-Output "$ModulePath\$ModuleName"
            Get-ChildItem -Path "$ModulePath\$ModuleName"

            try {
                #Uninstall
                Write-Output "`nUninstall all $ModuleName modules..." 
                Uninstall-module $ModuleName -force -allversions
            }
            catch {
                Write-Output "Unable to uninstall $ModuleName modules"
            }
        }
        catch {
            Write-Output "$ModuleName module folder not found"
        }
    }
    catch {
        Write-Output "Module $ModuleName not installed"
    }

    #Install 
    Write-Output "`nInstall latest version of $ModuleName" 
    if ($AllowPrerelease) {
        #If ##[error]Update-Module : A parameter cannot be found that matches parameter name ‘AllowPrerelease’.
        #Run PowerShell as Administrator and execute the following command

        #[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        #Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
        
        #Restart Powershell 

        Install-module $ModuleName -force -AllowPrerelease
    }
    else {
        Install-module $ModuleName -force 
    }

    #What version is installed.
    Write-Output "`nGet-InstalledModule $ModuleName ..."
    Get-InstalledModule $ModuleName | Select-Object Name, Version

    #Show module subfolders. Only one folder should be listed
    Write-Output "`nShow module subfolders. Only one folder should be listed..."
    Write-Output "$ModulePath\$ModuleName"
    Get-ChildItem -Path "$ModulePath\$ModuleName" 
}