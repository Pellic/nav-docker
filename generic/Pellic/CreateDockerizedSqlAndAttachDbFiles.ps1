#This script creates a Docker SQL container $DockerSQL and attach DB in folder $hostFolder

#Following commented lines are needed just to extract the demo db from the container image $imageName
#$imageName = "mcr.microsoft.com/businesscentral/onprem:it-ltsc2019"
#$path = "c:\ContainerDBFiles"
#Extract-FilesFromNavContainerImage -imageName $imageName -path $path -extract database -force

$hostFolder = "c:\ContainerDBFiles\databases"
$DockerSQL = "DockerizedSql"
$ClearDbUser = "sa"
$ClearDbPwd = "1qaz!QAZ"
$databaseCredential = New-Object System.Management.Automation.PSCredential -argumentList $ClearDbUser, (ConvertTo-SecureString -String $ClearDbPwd -AsPlainText -Force)

#Create a list of dbs to attach
#$attach_dbs = (ConvertTo-Json -Compress -Depth 99 @(@{"dbName" = "$databaseName"; "dbFiles" = @("c:\temp\${databaseName}.mdf", "c:\temp\${databaseName}.ldf") })).replace('"',"'")
[System.Collections.ArrayList]$AttachDbs = @(@{})
$ListFiles = Get-ChildItem -File -Path $hostFolder -Filter "*.mdf*" 
ForEach ($File in $ListFiles)
{
    Write-Host $File
    $db = (Get-Item "${hostFolder}\${File}").Basename
    $db
    $AttachDbs.Add(@{"dbName" = "$db"; "dbFiles" = @("c:\temp\${db}.mdf", "c:\temp\${db}.ldf") }) 
}
$attach_dbs = (ConvertTo-Json -Compress -Depth 99 @($AttachDbs)).replace('"',"'")
$AttachDbs
$dbPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($databaseCredential.Password))
$dbserverid = docker run -d --name "$DockerSQL" -e sa_password="$dbPassword" -e ACCEPT_EULA=Y -v "${hostFolder}:C:/temp" -e attach_dbs="$attach_dbs" microsoft/mssql-server-windows-developer

#$databaseServer = $dbserverid.SubString(0,12)
#$databaseInstance = ""
$SqlIP = docker inspect --format '{{.NetworkSettings.Networks.nat.IPAddress}}' "$DockerSQL"
$databaseServer = $SqlIP
Write-Host "The actual IP of $DockerSQL is $SqlIP"

#Eventually test the container against a simple query
#docker exec -it "$DockerSQL" /opt/mssql-tools/bin/sqlcmd -S localhost -U "$ClearDbUser" -P "$ClearDbPwd"
#$TestSqlContainer = sqlcmd -U "$ClearDbUser" -P "$ClearDbPwd" -S "$SqlIP" -Q "select @@version"
