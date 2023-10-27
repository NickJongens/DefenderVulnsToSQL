# DefenderVulnsToSQL
A script (&amp; container) to automatically pull vulnerabilities from the Microsoft Defender API and write to different types of SQL Server every 5 minutes. 

## Variants 

### Please see the corresponding branch for each type of database
- Microsoft SQL Server / MS SQL
- MySQL / MariaDB

### Data written
These columns will be written for each Vulnerability:

Id, Name, Description, Severity, CvssV3, ExposedMachines, PublishedOn, UpdatedOn, PublicExploit, ExploitVerified

The script will automatically ignore existing IDs to avoid re-write. These entries can be used to store and display data offline and/or be read by a web app.
