

function Get-StatusOnLatestBCArtifactURLs {   
    Param(
        $Version = "18",
        $Country = "IS"
    )

    Write-Output "Business Central $Version $Country "

    $ISClound = Get-BCArtifactUrl -country $Country -version $Version -select Latest
    $ISOnPrem = Get-BCArtifactUrl -country $Country -version $Version -select Latest -type OnPrem
    Write-Output $ISClound
    Write-Output $ISOnPrem


    Write-Output "Business Central $Version W1 "

    $W1Clound = Get-BCArtifactUrl -version $Version -select Latest
    $W1OnPrem = Get-BCArtifactUrl -version $Version -select Latest -type OnPrem
    
    Write-Output $W1Clound
    Write-Output $W1OnPrem
}