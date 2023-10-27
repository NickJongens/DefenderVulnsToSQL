# DefenderVulnsToSQL
A containerised script (&amp; container) to automatically pull from the Microsoft Defender API and write to different types of SQL Server every 10 minutes. 

## MS SQL (Microsoft SQL Server Express) 
This is the Microsoft SQL Server branch tailored to ingesting data into a MS SQL Express (or better) database. 
You can use the 'CreateTable.sql' file to input the table columns automatically.

For MySQL/MariaDB, please see the other branch.

# Build Docker Image

To build the Docker image, use the following commands:

```bash
sudo docker build -t defendervulnstomssql .
sudo docker tag defendervulnstomssql:latest <dockerhubusername>/defendervulnstomssql:latest
sudo docker push <dockerhubusername>/defendervulnstomssql:latest
```

# Deploy Unattended Docker Container for Continuous Upload
Use the following docker run command to deploy an unattended Docker container for continuous upload:

```bash
docker run -d --name DefenderVulnsToMSSQL \
  -e CLIENT_ID=<App ID/Client ID in App Registration> \
  -e CLIENT_SECRET=<Application Secret> \
  -e TENANT_ID=<Azure AD/Entra ID Tenant ID> \
  -e SERVER_NAME=<IP Address/Hostname OF SQL SERVER> \
  -e DATABASE_NAME=<Database Name> \
  -e DATABASE_TABLE=<Table Name e.g. DefenderVulns> \
  -e USERNAME=<DB Username> \
  -e PASSWORD=<DB Password> \
  nickjongens/defendervulnstomssql
