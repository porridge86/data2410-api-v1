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

## If we prepare a shared test data script before submission

### seed_data.sql

```sql
USE StudentsDb;
GO

TRUNCATE TABLE Students;
GO

INSERT INTO Students (Name, Course, Marks, Grade) VALUES
-- ('Per Hansen', 'DATA2410', 95, NULL)
-- ('Per Hansen', 'DATA2410', 95, NULL)
GO
```

### docker-compose.yml

```yml
db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: sql_server_db
    volumes:
      - ./seed_data.sql:/seed_data.sql
```
