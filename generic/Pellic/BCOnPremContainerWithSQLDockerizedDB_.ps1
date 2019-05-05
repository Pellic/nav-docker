#DATABASE:
$DockerSQL = "DockerizedSql"
$SqlIP = docker inspect --format '{{.NetworkSettings.Networks.nat.IPAddress}}' $DockerSQL
$databaseServer = $SqlIP 
$path = "c:\ContainerDBFiles"
$hostFolder = "$path\databases"
$databaseInstance = ""
$databaseName = "Cronusit"
$UserName = "sa"
$Password = "1qaz!QAZ"
$databaseCredential = New-Object System.Management.Automation.PSCredential -argumentList $UserName, (ConvertTo-SecureString -String $Password -AsPlainText -Force)
$dbPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($databaseCredential.Password))
$databaseServerInstance = @{ $true = "$databaseServer\$databaseInstance"; $false = "$databaseServer"}["$databaseInstance" -ne ""]

#NAV SERVICE
#$imageName = "microsoft/bcsandbox:it-ltsc2019"
#$imageName = "microsoft/dynamics-nav:11.0.21441.0-it-ltsc2019"
$imageName = "mcr.microsoft.com/businesscentral/onprem:it-ltsc2019"
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
$additionalParameters = @("--volume ${hostFolder}:c:\mydb")
#Public container for external access
$additionalParameters = @("--publish 8080:8080",
                          "--publish 443:443", 
                          "--publish 7046-7049:7046-7049")
$myscripts = @()
$shortcuts = "Desktop"
$licenseFile = 'C:\bkp pc lavoro\licenze nav\LICENZE\LICENZE\5165051_2018.flf'
$ContainerName = "bc-onprem-dev"

New-NavContainer -accept_eula `
                 -containerName $ContainerName `
                 -imageName $imageName `
                 -Auth NavUserPassword `
                 -Credential $navcredential `
                 -databaseServer $databaseServer `
                 -databaseInstance $databaseInstance `
                 -databaseName $databaseName `
                 -databaseCredential $databaseCredential `
                 -updateHosts `
                 -licenseFile $licenseFile `
                 <#-myScripts @($attachdbSetupDatabaseScript)#> `
                 -includeCSide `
                 -doNotExportObjectsToText `
                 -shortcuts $shortcuts `
                 <#-additionalParameters $additionalParameters #> `
                 -enableSymbolLoading 

New-NavContainerNavUser -ErrorAction Continue -containerName $ContainerName  -Credential $navcredential -PermissionSetId SUPER -ChangePasswordAtNextLogOn $false

#move shortcuts to a desktop folder
$directory= [System.Environment]::GetFolderPath('Desktop')
$NewDir = New-Item -ItemType Directory "$directory\$($ContainerName)" -Force
$ListFiles = Get-ChildItem -File -Path $directory -Filter "*$ContainerName*" 
ForEach ($File in $ListFiles)
{
    Move-Item -Path $File.FullName -Destination  "$directory\$($ContainerName)\$($File.Name)"      
}