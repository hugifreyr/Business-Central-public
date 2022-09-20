

function Get-SqlBackupFromBcContainer {
    Param(
        [String] $SQLBackupPath = "C:\SQL Server\Backup",
        [String] $BcContainerPath = "C:\ProgramData\BcContainerHelper\Extensions",
        [parameter(Mandatory = $true)]
        [String] $ContainerName
    )

    $Version = Get-BcContainerNavVersion -containerOrImageName $ContainerName
    $ContainerConfiguration = Get-BcContainerServerConfiguration -ContainerName $ContainerName

    if ($ContainerConfiguration.Multitenant -eq "true") {
        Write-Host "Multitenant: true" -ForegroundColor Yellow
        Backup-BCContainerDatabases -containerName $ContainerName -bakFolder "$BcContainerPath\${ContainerName}\my\" -tenant default

        $SQLBackup = "$SQLBackupPath\${ContainerName}-${Version}-app.bak"
        Move-Item -Path "$BcContainerPath\${ContainerName}\my\app.bak" -Destination $SQLBackup -Force
        $SQLBackup = "$SQLBackupPath\${ContainerName}-${Version}-default.bak"
        Move-Item -Path "$BcContainerPath\${ContainerName}\my\default.bak" -Destination $SQLBackup -Force
    }
    else {
        Write-Host "Multitenant: false" -ForegroundColor Yellow

        Backup-BCContainerDatabases -containerName $ContainerName -bakFolder "$BcContainerPath\${ContainerName}\my\" 

        $SQLBackup = "$SQLBackupPath\${ContainerName}-${Version}-database.bak"
        Move-Item -Path "$BcContainerPath\${ContainerName}\my\database.bak" -Destination $SQLBackup -Force
    }

}





function Get-BCDevSQLRestore () {
    Param(
        [String] $SQLBackupPath = "C:\SQL Server\Backup",
        [String] $SQLDataPath = "C:\SQL Server\Data",
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $DBCredential = [System.Management.Automation.PSCredential]::Empty

    )

    $type = "Sandbox"
    $DatabaseName = "bc202local-default"
    $SQLBackup = "$SQLBackupPath\$DatabaseName.bak"

    $srv = new-object ('Microsoft.SqlServer.Management.Smo.Server') Localhost
    $rs = new-object('Microsoft.SqlServer.Management.Smo.Restore')
    $bdi = new-object ('Microsoft.SqlServer.Management.Smo.BackupDeviceItem') ("$SQLBackup", 'File')

    $rs.Devices.Add($bdi)
    $fl = $rs.ReadFileList($srv)
    $logname = $fl.logicalname

    # Virkar ekki ef skrár koma frá path sem var til þar sem afritið var gert en ekki til á vélinni sem á að restore-a á.
    $RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile($logname.Item(0), "$SQLDataPath\${DatabaseName}_Data.mdf")
    $RelocateLog = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile($logname.Item(1), "$SQLDataPath\${DatabaseName}_Log.ldf")

    Restore-SqlDatabase -ServerInstance localhost -Database $DatabaseName -BackupFile $SQLBackup -RelocateFile @($RelocateData, $RelocateLog) -ReplaceDatabase
    Invoke-Sqlcmd -Query "CREATE USER [$($DBCredential.UserName)] FOR LOGIN [$($DBCredential.UserName)]" -ServerInstance localhost -Database $DatabaseName
    Invoke-Sqlcmd -Query "ALTER ROLE [db_owner] ADD MEMBER [$($DBCredential.UserName)]" -ServerInstance localhost -Database $DatabaseName
    Invoke-Sqlcmd -Query "ALTER DATABASE [$DatabaseName] SET RECOVERY SIMPLE" -ServerInstance localhost -Database $DatabaseName
 
    if ( $type -eq "Sandbox") {
        Invoke-Sqlcmd -Query "DELETE FROM [dbo].[`$ndo`$tenants]" -ServerInstance localhost -Database $DatabaseName
    }

}