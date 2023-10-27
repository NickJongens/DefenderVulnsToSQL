# Import SimplySQL module
Import-Module SimplySQL

# Define your API endpoint for Microsoft Defender for Office 365 ATP
$apiEndpoint = "https://api.securitycenter.microsoft.com/api/Vulnerabilities"

$clientId = $env:CLIENT_ID
$clientSecret = $env:CLIENT_SECRET
$tenantId = $env:TENANT_ID

$serverName = $env:SERVER_NAME
$databaseName = $env:DATABASE_NAME
$databaseTable = $env:DATABASE_TABLE
$username = $env:USERNAME
$password = $env:PASSWORD

# Convert the password to a secure string
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)
try {
    # Obtain an access token for Microsoft Defender for Office 365 ATP
    $tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $tokenParams = @{
        client_id     = $clientId
        scope         = "https://api.securitycenter.microsoft.com/.default"
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }

    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenParams
    $accessToken = $tokenResponse.access_token

    # Use the access token to call Microsoft Defender for Office 365 ATP and retrieve vulnerabilities
    $vulnerabilities = Invoke-RestMethod -Uri $apiEndpoint -Headers @{ "Authorization" = "Bearer $accessToken" }

    # Write the retrieved data to SQL Server
    $connection = Open-SqlConnection -Server $serverName -Database $databaseName -Credential $credential

    # Define the SQL query to insert data
    $query = @"
    INSERT INTO $DatabaseTable (
        Id,
        Name,
        Description,
        Severity,
        CvssV3,
        ExposedMachines,
        PublishedOn,
        UpdatedOn,
        PublicExploit,
        ExploitVerified
    )
    SELECT
        @Id,
        @Name,
        @Description,
        @Severity,
        @CvssV3,
        @ExposedMachines,
        @PublishedOn,
        @UpdatedOn,
        @PublicExploit,
        @ExploitVerified
    WHERE NOT EXISTS (
        SELECT 1 FROM Vulnerabilities WHERE Id = @Id
    )
"@

    # Loop through the vulnerabilities and execute the SQL query for each record
    foreach ($vuln in $vulnerabilities.value) {
        # Add debug information to see which severity is being processed
        Write-Host "Processing vulnerability with Severity: $($vuln.severity)"
        
        # Check if the severity is "Critical" or "High" and machines exposed is greater than 0
        if (($vuln.severity -eq "Critical" -or $vuln.severity -eq "High") -and $vuln.exposedMachines -gt 0) {
            $params = @{
                "@Id"               = $vuln.id
                "@Name"             = $vuln.name
                "@Description"      = $vuln.description
                "@Severity"         = $vuln.severity
                "@CvssV3"           = $vuln.cvssV3
                "@ExposedMachines"  = $vuln.exposedMachines
                "@PublishedOn"      = $vuln.publishedOn
                "@UpdatedOn"        = $vuln.updatedOn
                "@PublicExploit"    = $vuln.publicExploit
                "@ExploitVerified"  = $vuln.exploitVerified
            }

            # Check if a record with the same ID already exists in the Vulnerabilities table
            $recordExistsQuery = "SELECT 1 FROM $databaseTable WHERE Id = @Id"
            $recordExists = Invoke-SqlQuery -Query $recordExistsQuery -Parameters $params

            if ($recordExists -eq $null) {
                # The record doesn't exist, so insert it
                Write-Host "Inserting data into SQL table"

                try {
                    # Execute the SQL query with parameters
                    Invoke-SqlUpdate -Query $query -Parameters $params
                    Write-Host "Data successfully inserted into the Vulnerabilities table."
                }
                catch {
                    Write-Host "Error inserting data: $_"
                    # You can log the error to a file or perform other error handling actions here
                }
            }
            else {
                Write-Host "Data with Id $($params['@Id']) already exists in the table. Skipping insertion."
            }
        }
    }

    # Close the SQL connection
    Close-SqlConnection

    Write-Host "Data successfully written to SQL Server."
}
catch {
    Write-Host "Error: $_"
}
