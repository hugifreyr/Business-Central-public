

    Enter-BcContainer -containerName rv1405
    Copy-Item -Path C:\Run\add-ins\* -Destination . -Recurse -Force
    Set-NAVServerInstance nav -Restart