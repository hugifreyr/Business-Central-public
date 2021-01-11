
function Get-CodeSignMyApps {
    Param(
        #AppFolder need to end with "\"
        [String]
        $AppFolder = "C:\BC\CodeSigning\"
        ,
        [String]
        $SignToolFolder = "C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool"
        ,
        [String]
        $PfxFilePath = "C:\BC\AdvCodeSigning2022.pfx"
        ,
        [parameter(Mandatory = $true)]
        [securestring]
        $PfxPassword
    )

    $files = Get-ChildItem -Path $AppFolder -Recurse
    
    Set-Location $SignToolFolder
    Write-Output "cd `"$SignToolFolder`""
    foreach ( $suffix in $files ) {
        $name = $suffix.Name
        $file = $AppFolder + $name
        try {
            $tmp = "SignTool sign /v /f `"$PfxFilePath`" /p `"$PfxPassword`" /t http://timestamp.digicert.com `"$file`""
            Write-Output $tmp
            cmd.exe /c $tmp
            $tmp = "signtool verify /pa /v `"$file`""
            Write-Output $tmp
            cmd.exe /c $tmp
        }
        finally {
        }
    }
}