
#NAV SERVICE
#$imageName = "microsoft/bcsandbox:it-ltsc2019"
#$imageName = "microsoft/dynamics-nav:11.0.21441.0-it-ltsc2019"
$imageName = "mcr.microsoft.com/businesscentral/onprem:1904-rtm"
$NavUserName = "EMPE"
$NavPassword = "1qaz!QAZ"
$navcredential = New-Object System.Management.Automation.PSCredential -argumentList $NavUserName, (ConvertTo-SecureString -String $NavPassword -AsPlainText -Force)
if ($navcredential -eq $null -or $navcredential -eq [System.Management.Automation.PSCredential]::Empty)
{
    $navcredential = get-credential -UserName "admin" -Message "Enter NAV Super User Credentials"
}
<#
alProjectFolder should be in a location,
which is shared with the container,
a folder underneath C:\ProgramData\NavContainerHelper will work.
#>
$projectFolder = "C:\ProgramData\NavContainerHelper\AL\DemoSolution"

#Additional parameters examples
$workspaceFolder = (Get-Item (Join-Path $PSScriptRoot "..")).FullName
$additionalParameters = @("--volume ""${workspaceFolder}:C:\Source""") 
$additionalParameters = @("--env clickonce=Y")
$addInsFolder = "C:\temp\addins"
$additionalParameters = @("--volume ${addInsFolder}:c:\run\Add-Ins")

#Public container for external access
$publicdnsName = "bc-onprem-rtm"
$additionalParameters = @("--publish 8080:8080",
                          "--publish 80:80",
                          "--publish 443:443", 
                          "--publish 7046-7049:7046-7049"
                          "--env PublicDnsName=$publicdnsName"
                          )
#$myscripts = @()
$shortcuts = "Desktop"
$licenseFile = 'C:\bkp pc lavoro\licenze nav\LICENZE\LICENZE\5165051.flf'
$ContainerName = "bc-onprem-rtm"

New-NavContainer -accept_eula `
                 <#-useSSL#> `
                 -containerName $ContainerName `
                 -imageName $imageName `
                 -Auth NavUserPassword `
                 -Credential $navcredential `
                 -updateHosts `
                 -licenseFile $licenseFile `
                 <#-myScripts @($attachdbSetupDatabaseScript)#> `
                 <#-enableSymbolLoading#> `
                 <#-includeCSide#> `
                 -includeAL `
                 -doNotExportObjectsToText `
                 -shortcuts $shortcuts `
                 -additionalParameters $additionalParameters


New-NavContainerNavUser -ErrorAction Continue -containerName $ContainerName  -Credential $navcredential -PermissionSetId SUPER -ChangePasswordAtNextLogOn $false

#move shortcuts to a desktop folder
$directory= [System.Environment]::GetFolderPath('Desktop')
$NewDir = New-Item -ItemType Directory "$directory\$($ContainerName)" -Force
$ListFiles = Get-ChildItem -File -Path $directory -Filter "*$ContainerName*" 
ForEach ($File in $ListFiles)
{
    Move-Item -Path $File.FullName -Destination  "$directory\$($ContainerName)\$($File.Name)" -Force     
}
$NewDir

#BASE APP CUSTOMIZATION
<#
Create a project folder with all base application objects,
setup app.json with reference to platform only,
launch.json with reference to your development container and a settings.json with assemblyProbingPaths to the shared folder from this container
#>
#Create-AlProjectFolderFromNavContainer -containerName $ContainerName -alProjectFolder $projectFolder -useBaseLine -addGIT

#eventually compile
#Compile-AppInNavContainer -containerName $ContainerName -credential $navcredential -appProjectFolder $projectFolder

<#
uninstalls all apps,
removes all C/AL objects and use the development endpoint of the container to publish the new app
#>
#Publish-NewApplicationToNavContainer -containerName $ContainerName -appDotNetPackagesFolder "${projectFolder}.netpackages" -appFile "${projectFolder}\output\Default Publisher_${ContainerName}_1.0.0.0.app" -credential $navcredential -useCleanDatabase