
# Note

## Setup for Team Development

This project uses Docker to keep the environment consistent between Mac and Windows.

### 1. Create a `.env` file in the root directory

### 2. Add `DB_PASSWORD=YourStrongPassword123!` to the `.env` file

Example:

```txt
DB_PASSWORD=YourStrongPassword123!
```

### 3. Run `docker-compose up --build`

- **Note:** The database `StudentsDb` will be created automatically. You don't need SSMS or Azure Data Studio for initial setup!

## `appsettings.Development.json`

### mac

```json
{
    "ConnectionStrings": {
        "DefaultConnection": "Server=localhost,1433;Database=StudentsDb;User ID=sa;Password=${DB_PASSWORD};TrustServerCertificate=True;"
    }
}
```

#### win

```json
{
    "ConnectionStrings": {
        "DefaultConnection": "Server=localhost;Database=StudentsDb;Trusted_Connection=True;TrustServerCertificate=True;"
    }
}
```
