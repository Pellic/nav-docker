
<#
Navigate to https://mcr.microsoft.com/v2/windows/servercore/insider/tags/list 
and identify the best tag.
The best tag is the newest build with the same build number as your host OS
In the generic folder you will find a script called mybuild.ps1,
edit that and set the baseimage tag to the one identified earlier as the best.
Also modify the image name and genericversion if necessary.
Run the script and after a while, you should have an image locally on your machine
called mygeneric:latest – your own private generic image.
#>
$hyperv = $false
# Settings
$imageName = "mcr.microsoft.com/businesscentral/onprem:1904-rtm"
$auth = "NavUserPassword"
$credential = New-Object pscredential 'EMPE', (ConvertTo-SecureString -String '1qaz!QAZ' -AsPlainText -Force)
$imageName = Get-BestNavContainerImageName -imageName $imageName

if ($hyperv) {
    $imageParam = @{ 
        "imageName" = $imageName
        "memoryLimit" = "8G"
    }
}
else {
    docker pull $imageName
    $navVersion = Get-NavContainerNavVersion -containerOrImageName $imageName
    $navDvdPath = "c:\ProgramData\NavContainerHelper\$($NavVersion)-Files"
    if (!(Test-Path $navDvdPath)) {
        Extract-FilesFromNavContainerImage -imageName $imageName -path $navDvdPath
    }
    $imageParam = @{
        "imageName" = "mygeneric"
        "navdvdPath" = $navDvdPath
        "navDvdCountry" = ($navVersion.Split('-')[1])
    }
}

New-NavContainer -accept_eula @imageParam `
                 -containerName "bc" `
                 -auth $auth `
                 -Credential $Credential `
                 -updateHosts 