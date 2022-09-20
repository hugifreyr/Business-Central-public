

function Get-StatusOnLatestBCArtifactURLs {   
    Param(
        $Version = "21",
        $Country = "IS"
    )

    Write-Output "Business Central $Version $Country "

    $ISCloud = Get-BCArtifactUrl -country $Country -version $Version -select Latest
    $ISOnPrem = Get-BCArtifactUrl -country $Country -version $Version -select Latest -type OnPrem
    Write-Output $ISCloud
    Write-Output $ISOnPrem


    Write-Output "Business Central $Version W1 "

    $W1Cloud = Get-BCArtifactUrl -version $Version -select Latest
    $W1OnPrem = Get-BCArtifactUrl -version $Version -select Latest -type OnPrem
    
    Write-Output $W1Cloud
    Write-Output $W1OnPrem
}