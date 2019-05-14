
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

#Additional parameters examples
$workspaceFolder = (Get-Item (Join-Path $PSScriptRoot "..")).FullName
$additionalParameters = @("--volume ""${workspaceFolder}:C:\Source""") 
$additionalParameters = @("--env clickonce=Y")
$addInsFolder = "C:\temp\addins"
$additionalParameters = @("--volume ${addInsFolder}:c:\run\Add-Ins")

#Public container for external access
$additionalParameters = @("--publish 8080:8080",
                          "--publish 80:80",
                          "--publish 443:443", 
                          "--publish 7046-7049:7046-7049")
#$myscripts = @()
$shortcuts = "Desktop"
$licenseFile = 'C:\bkp pc lavoro\licenze nav\LICENZE\LICENZE\5165051_2018.flf'
$ContainerName = "bc-onprem-rtm"

New-NavContainer -accept_eula `
                 -useSSL `
                 -containerName $ContainerName `
                 -imageName $imageName `
                 -Auth NavUserPassword `
                 -Credential $navcredential `
                 -updateHosts `
                 -licenseFile $licenseFile `
                 <#-myScripts @($attachdbSetupDatabaseScript)#> `
                 -includeCSide `
                 -doNotExportObjectsToText `
                 -shortcuts $shortcuts `
                 -additionalParameters $additionalParameters `
                 -enableSymbolLoading 

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