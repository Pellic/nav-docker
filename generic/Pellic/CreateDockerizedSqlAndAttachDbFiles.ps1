
#$imageName = "microsoft/bcsandbox:it-ltsc2019"
$imageName = "mcr.microsoft.com/businesscentral/onprem:it-ltsc2019"
$path = "c:\ContainerDBFiles"
#Extract-FilesFromNavContainerImage -imageName $imageName -path $path -extract database -force

$hostFolder = "$path\databases"
$ClearDbUser = "sa"
$ClearDbPwd = "1qaz!QAZ"
$databaseCredential = New-Object System.Management.Automation.PSCredential -argumentList $ClearDbUser, (ConvertTo-SecureString -String $ClearDbPwd -AsPlainText -Force)
$databaseName = "Cronusit"

#Create a list of dbs to attach
#$attach_dbs = (ConvertTo-Json -Compress -Depth 99 @(@{"dbName" = "$databaseName"; "dbFiles" = @("c:\temp\${databaseName}.mdf", "c:\temp\${databaseName}.ldf") })).replace('"',"'")
[System.Collections.ArrayList]$AttachDbs = @(@{"dbName" = "$databaseName"; "dbFiles" = @("c:\temp\${databaseName}.mdf", "c:\temp\${databaseName}.ldf") })
$DbsToAttach = @("FinancialsIT","DemoNAV2009") #Add DB to attach in this list
foreach ($db in $DbsToAttach)
{
    $AttachDbs.Add(@{"dbName" = "$db"; "dbFiles" = @("c:\temp\${db}.mdf", "c:\temp\${db}.ldf") })
}
$attach_dbs = (ConvertTo-Json -Compress -Depth 99 @($AttachDbs)).replace('"',"'")
$AttachDbs

$dbPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($databaseCredential.Password))
$DockerSQL = "DockerizedSql"
$dbserverid = docker run -d --name "$DockerSQL" -e sa_password="$dbPassword" -e ACCEPT_EULA=Y -v "${hostFolder}:C:/temp" -e attach_dbs="$attach_dbs" microsoft/mssql-server-windows-developer
$databaseServer = $dbserverid.SubString(0,12)
$databaseInstance = ""
$SqlIP = docker inspect --format '{{.NetworkSettings.Networks.nat.IPAddress}}' "$DockerSQL"
$databaseServer = $SqlIP
#docker exec -it "$DockerSQL" /opt/mssql-tools/bin/sqlcmd -S localhost -U "$ClearDbUser" -P "$ClearDbPwd"
#$TestSqlContainer = sqlcmd -U "$ClearDbUser" -P "$ClearDbPwd" -S "$SqlIP" -Q "select @@version"
