#DATABASE:
<#
$DockerSQL = "DockerizedSql"
$SqlIP = docker inspect --format '{{.NetworkSettings.Networks.nat.IPAddress}}' $DockerSQL
$databaseServer = $SqlIP 
$path = "c:\ContainerDBFiles"
$hostFolder = "$path\databases"
$databaseInstance = ""
$databaseName = "DemoNAV2009"
$UserName = "sa"
$Password = "1qaz!QAZ"
$databaseCredential = New-Object System.Management.Automation.PSCredential -argumentList $UserName, (ConvertTo-SecureString -String $Password -AsPlainText -Force)
$dbPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($databaseCredential.Password))
$databaseServerInstance = @{ $true = "$databaseServer\$databaseInstance"; $false = "$databaseServer"}["$databaseInstance" -ne ""]
#>



$licenseFile = 'C:\bkp pc lavoro\licenze nav\LICENZE\LICENZE\5165051_2018.flf'
$navcredential = New-Object System.Management.Automation.PSCredential -argumentList $NavUserName, (ConvertTo-SecureString -String $NavPassword -AsPlainText -Force)
if ($navcredential -eq $null -or $navcredential -eq [System.Management.Automation.PSCredential]::Empty)
{
    $navcredential = get-credential -UserName "admin" -Message "Enter NAV Super User Credentials"
}
New-NavContainer -accept_eula `
                 -containerName nav2009r2 `
                 -imageName "microsoft/dynamics-nav:generic-ltsc2019" `
                 -navDvdPath "C:\InstallerNAV\nav2009r2" `
                 -navDvdCountry it `
                 <#
                 -Auth NavUserPassword `
                 -Credential $navcredential `
                 -databaseServer $databaseServer `
                 -databaseInstance $databaseInstance `
                 -databaseName $databaseName `
                 -databaseCredential $databaseCredential `
                 #> `
                 -updateHosts `
                 -doNotExportObjectsToText `
                 -Verbose `
                 <#-ErrorAction Continue#> `
                 -myScripts @("C:\bkp pc lavoro\PS samples\NavDocker\nav-docker\generic\Run\60") `
                 -licenseFile $licenseFile `
                 -shortcuts "Desktop" `
                 -includeCSide