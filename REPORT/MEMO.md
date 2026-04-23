# Student Management API: Report MEMO

Student no.:

## 1. Implementation Memo

### Task 1: Asynchronous Database Operations

In implementing the calculate-grades endpoint, I utilized **asynchronous method** for database connection and data handling.

While synchronous method with `reader.Close()` stops server processing completely until the database finishes the closing operation, asynchronous method with `await reader.CloseAsync()` allows the server's CPU to process other incoming requests simultaneously when the database is closing. Cloud servers need to handle hundreds of requests simultaneously. If each process involves a "wait," the entire network becomes overloaded. Asynchronous processing prevents the network from becoming overloaded and improves overall server responsiveness.

## 2. Test Data Generation

I asked AI to generate a test dataset for eight students, consisting of common Norwegian names and varied marks for subjects DATA2410 and DATA1300.

I manually registered data in the database by sending individual requests through the `POST /api/Students` endpoint via the interactive Scalar interface at <https://localhost:7010/scalar/v1>.

![picture](/REPORT/Scalar-API-Reference-12_40.png)

I confirmed that the server returned the correct response (e.g., `201 Created`) for each POST request.

![picture](/REPORT/Scalar-API-Reference-12_39.png)

After that, I executed the `POST /api/Students/calculate-grades` endpoint to trigger the server-side grading logic.

![picture](/REPORT/Scalar-API-Reference-12_41.png)

I verified that the API correctly processed the stored marks and updated the database, confirming that the grades (A, B, C, and D) were accurately assigned based on the defined grading scale.

Initially, the marks had distribution of A, B, A, and C for DATA2410. To verify the API's ability to recalculate and update existing records, I performed the following steps:

Data Modification: I used the `PUT /api/Students/{id}` endpoint to modify the marks of specific students.

![picture](/REPORT/Scalar-API-Reference-12_58.png)

Triggering Recalculation: After updating the marks, I executed the `POST /api/Students/calculate-grades` endpoint.

![picture](/REPORT/Scalar-API-Reference-13_04.png)

Verification: I confirmed that the application correctly read the updated marks from the database, applied the grading logic via the `GetGrade()` method, and successfully overwrote the Grade with the new values.

This process successfully demonstrated that the service maintains data consistency between marks and grades even after student records are modified.

### Data

```json
  {
    "id": 1,
    "name": "Per Hansen",
    "course": "DATA2410",
    "marks": 95,
    "grade": "A"
  },
  {
    "id": 2,
    "name": "Bjørn Olsen",
    "course": "DATA2410",
    "marks": 82,
    "grade": "B"
  },
  {
    "id": 3,
    "name": "Anne Pedersen",
    "course": "DATA2410",
    "marks": 75,
    "grade": "C"
  },
  {
    "id": 4,
    "name": "Mohammad Ahmed",
    "course": "DATA2410",
    "marks": 55,
    "grade": "D"
  },
  {
    "id": 5,
    "name": "Sara Nguyen",
    "course": "DATA1300",
    "marks": 98,
    "grade": "A"
  },
  {
    "id": 6,
    "name": "Amina Abdi",
    "course": "DATA1300",
    "marks": 88,
    "grade": "B"
  },
  {
    "id": 7,
    "name": "Ole Nilsen",
    "course": "DATA1300",
    "marks": 75,
    "grade": "C"
  },
  {
    "id": 8,
    "name": "Kjell Larsen",
    "course": "DATA1300",
    "marks": 45,
    "grade": "D"
  }

```

### sql from terminal

```bash
docker exec -it sql_server_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YOURPASSWORD' -C
```

```sql
USE StudentsDb;
INSERT INTO Students (Name, Course, Marks, Grade) VALUES
('Per Hansen', 'DATA2410', 95, NULL),
('Bjørn Olsen', 'DATA2410', 82, NULL),
('Anne Pedersen', 'DATA2410', 75, NULL),
('Mohammad Ahmed', 'DATA2410', 55, NULL),
('Sara Nguyen', 'DATA1300', 98, NULL),
('Amina Abdi', 'DATA1300', 88, NULL),
('Ole Nilsen', 'DATA1300', 75, NULL),
('Kjell Larsen', 'DATA1300', 45, NULL);
```

## 2-2. Automated Database Provisioning

We are agreed to prepare a shared test data script before submission.

This eliminates the need to manually re-enter data and ensures **"the same data state can be reproduced regardless of who executes it or where (environmental reproducibility)"**.

To ensure environment consistency and simplify the development workflow, I implemented an automated database seeding process using Docker and SQL scripts.

### 1. Infrastructure Setup

* **Custom DB Image**: Created a `db.Dockerfile` based on `mssql/server:2022-latest` to include custom initialization logic.

```dockerfile
# Dockerfile for db
# We have two dockerfile because the app (.NET) and the database (SQL Server) are separate environments, whitch means  two different containers!
FROM mcr.microsoft.com/mssql/server:2022-latest

USER root
COPY init.sh /init.sh
COPY seed_data.sql /seed_data.sql
RUN chmod +x /init.sh

USER mssql
ENTRYPOINT ["/bin/bash", "-c", "/init.sh & /opt/mssql/bin/sqlservr"]
```

* **Initialization Script**:

The reason for creating a custom `init.sh` is that SQL Server does not have a built-in automatic execution folder like MySQL.

Developed `init.sh` to handle the "race condition" between the SQL Server startup and script execution.

The script waits for the SQL engine to be fully operational before injecting data.

```bash
#!/bin/bash

# Wait for SQL Server to start up before executing seed_data.sql
# This is because SQL Server does not have an automated execution feature like MySQL does by default.
echo "Waiting for SQL Server to start..."
for i in {1..60}; do
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -Q "SELECT 1" &> /dev/null
    if [ $? -eq 0 ]; then
        echo "SQL Server is up - executing script"
        # run seed_data.sql
        /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -i /seed_data.sql
        break
    fi
    echo "Not ready yet..."
    sleep 1
done
```

* **Multi-Container Orchestration**: Configured `docker-compose.yml` with `healthcheck` and `depends_on`. This ensures the .NET API only attempts to connect once the database is healthy and the schema is ready.

```yml
services:
  db:
    # not auto-db
    #    image: mcr.microsoft.com/mssql/server:2022-latest # SQL Server 2025 is also available but 2022 is stable
    # auto-db creation
    build:
      context: . # # the folder where Dockerfile exits
      dockerfile: db.Dockerfile # Dockerfile for DB
    container_name: sql_server_db
    ports:
      - "1433:1433"
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_SA_PASSWORD=${DB_PASSWORD} # Set your password in .env
    healthcheck:
      # By combining `depends_on` and `healthcheck`, we manage the service startup order, ensuring that the application is launched only after the database is fully prepared.
      test: [ "CMD-SHELL", "/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '${DB_PASSWORD}' -Q 'SELECT 1' -b -C" ]
      interval: 10s
      timeout: 3s
      retries: 10
  app:
    build: . # This uses a Dockerfile for .NET
    container_name: student_api_app
    ports:
      - "7010:8080" # Maps local port 7010 to container port 8080
    depends_on:
      # By combining `depends_on` and `healthcheck`, we manage the service startup order, ensuring that the application is launched only after the database is fully prepared.
      db:
        condition: service_healthy
    environment:
      # Ensure the password here matches the one set in the 'db' service above (.env)
      - ConnectionStrings__DefaultConnection=Server=db;Database=StudentsDb;User ID=sa;Password=${DB_PASSWORD};TrustServerCertificate=True;

```

### 2. Database Seeding Logic

* **Idempotent SQL Script**: Authored `seed_data.sql` using `IF NOT EXISTS` clauses for database and table creation. This ensures the script is **idempotent**, meaning it can be executed multiple times without causing errors or duplicate schemas.
* **Test Data Population**: Automatically populated the `Students` table with 8 predefined student records (Norwegian dataset) to facilitate immediate testing of the API endpoints.

### 3. Benefits from a Cloud & Networking Perspective

* **Portability**: By containerizing the initialization logic, the entire environment—including its data state—can be reproduced on any machine (macOS, Windows, or Linux) with a single command: `docker compose up`.
* **Scalability & DevOps**: This approach mimics professional CI/CD pipelines where infrastructure is provisioned automatically, reducing manual configuration errors and ensuring a "Single Source of Truth" for the testing environment.

### 4. Setup Procedure

Now we have the following files in the project's root folder:

* `docker-compose.yml`
* `Dockerfile` (Dockerfile for the application)
* `db.Dockerfile` (Dockerfile for the database)
* `init.sh` (for automatic database execution)
* `seed_data.sql` (initial database data)
* `.env` (for password settings)

#### 2. Clean up old container and create a create container

```bash
docker compose down
```

```bash
docker compose up --build
```

* Adding `--build` creates a custom image based on the newly created `db.Dockerfile`.

#### 3. **Verification of Startup**

If `SQL Server is up - executing script` is displayed in the terminal, automatic seeding (data insertion) was successful.

#### 4. **Verification with Scalar**

Access `http://localhost:7010/scalar/v1` and execute `GET /api/Students` to verify that data for 8 people has been inserted.
