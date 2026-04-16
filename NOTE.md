# Development Setup Guide

This project uses Docker to maintain a consistent SQL Server environment across Mac and Windows.

## 0. Crone the repository

```bash
git clone https://github.com/porridge86/data2410-api-v1.git
cd data2410-api-v1
```

## 1.Create `.env` file

Since passwords is not included in Git, create a `.env` file manually in the root directory and set your database password.

```txt
DB_PASSWORD=YourStrongPassword123!
```

## 2. Infrastructure Setup (Docker)

Run the following command to start the SQL Server container:

```Bash
docker-compose up -d
```

## 3. Database Initialization

According to the assignment, we must create an empty database named **StudentsDb** before running the application.

### Important Note for Mac Users

- While the assignment mentions ***SQL Server 2025 Developer***, it is not natively available on macOS.
- Additionally, ***Azure Data Studio*** was retired in February 2026.
So, I use the [MSSQL extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql) for database management.

### Steps to create the database

1. Open SQL Tool:

- Windows: SSMS (SQL Server Management Studio)
- Mac: VS Code with MSSQL extension

1. Connection Settings:

- Server: localhost,1433
- Authentication: SQL Login
- User: sa
- Password: (The one you set in .env)

1. Execute Script:
Open and execute `CreateStudentsDb.sql` in the root folder. This will create the **StudentsDb** container.

## 4. Configuration (Cross-Platform Compatibility)

After cloning the repository, Windows users may need to adjust the connection string in `appsettings.Development.json` to match their local environment.

***Ensure the password(`YourStrongPassword123!`) matches your `.env` file exactly.***

### For Mac Users /Docker Users

Uses `Server=localhost,1433;User ID=sa;...` to point to the SQL Server running inside the Docker container.

```JSON

{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost,1433;Database=StudentsDb;User ID=sa;Password=YourStrongPassword123!;TrustServerCertificate=True;"
  }
}
```

### For Windows Users (Local SQL Server)

If you are running SQL Server 2025 Developer natively on Windows:

```JSON
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=StudentsDb;User ID=sa;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

### Conditions for Identical Behavior

The application will behave identically across both OS environments as long as the following two conditions are met:

- Consistent Database Name:

Both users must create an empty database named **StudentsDb**. Once created, EF Core (C#) will automatically generate the identical table schema in both environments upon startup.

- SQL Server Version Compatibility:

The SQL Server `2022-latest` used in the Mac Docker environment and the SQL Server `2025 Developer` installed on Windows are supposed to be fully compatible for the scope of this project.

## 5. Running the Application

Start the Web API:

```Bash
dotnet run
```

### Verification

Open your browser and check:

- Health Check: <https://localhost:7010/health>

Should display like this : `{"database":"Connected","server":"localhost,1433"}`

- Student API: <https://localhost:7010/api/Students>

Should display : `[]`(Empty array indicates table was auto-created successfully)
