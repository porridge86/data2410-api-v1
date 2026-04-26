
# Student Management API (DATA2410 - Assignment 3)

This repository contains a RESTful Web API built for the **DATA2410** course in OsloMet.

This was a **group project** completed by [porridge86](https://github.com/porridge86/data2410-api-v1) and [sakha7445](https://github.com/sakha7445/data2410-api-v1).

## 1. Introduction

This project is a Student Management API built with **C# (.NET 10)** and **SQL Server**.
As we developed this on **macOS**, we used **Docker** to run SQL Server. This ensures the application works the same way for everyone, regardless of their operating system.

### Key Features

* **Two-Tier Architecture**: The API and Database run in separate Docker containers.
* **Microservices Design**: The system is flexible; you can move the database to the cloud (like Azure SQL) just by changing the connection settings.
* **Automated Setup**: The database and test data are created automatically when the container starts.

## 2. Environment Setup

The system uses the following components:

* **`docker-compose.yml`**: Manages both the API and Database.
* **`Dockerfile` & `db.Dockerfile`**: Build the application and SQL Server images.
* **`init.sh` & `seed_data.sql`**: Automatically create tables and insert 8 starting records.
* **`appsettings.json`**: Stores the database connection string.

### How to Start

1. Create a `.env` file in the root folder with: `DB_PASSWORD=your_password`.
2. Run the command: `docker compose up --build`.
3. Open the API at: `https://localhost:7010/scalar/v1`.

## 3. API Implementation

We shared the development tasks to implement the following core logic:

### 3.1 Grade Calculation (`POST /api/Students/calculate-grades`)

* **Logic**: Reads student marks and assigns a grade (A-D) using the `GetGrade` helper.
* **Performance**: Uses **Asynchronous I/O** (`OpenAsync`, `ReadAsync`) to keep the server fast and responsive.
* **Verification**: Confirmed via **200 OK** responses in Scalar.

### 3.2 Course Report (`GET /api/Students/report`)

* **Logic**: Groups students by course and calculates the total count, average marks, and grade distribution (A, B, C, D).
* **Efficiency**: Uses a single SQL query with `GROUP BY` to minimize database workload.

## 4. Conclusion & Lessons Learned

* **Docker is Essential**: It allowed us to use Windows-based SQL Server on macOS seamlessly and ensured a consistent environment for both team members.
* **API as a Contract**: We learned that a Web API is a "contract" between client and server. By keeping the JSON format and endpoints strict, we can change the backend (like moving to the cloud) without breaking the client.
* **Cloud Readiness**: Using the OSI Application Layer (HTTP/JSON) makes the system ready for modern "Local Cloud" or production environments.

---

The following are the instructions for the assignment.

---

##### Assignment #3

# Building an HTTP Web API Service

---

## Introduction

We have learned about the **HTTP protocol** - how clients send requests and servers respond, the structure of HTTP messages, methods like GET, POST, PUT, and DELETE, status codes, and how the web browser communicates using this protocol.

In this assignment, you will practice how to **build an HTTP-based service** (a Web API) that interacts with a **local SQL database**. You will work with a real-world scenario: a **Student Management API** that stores student records, calculates grades, and generates course-wise reports.

---

## What is an API?

An **API (Application Programming Interface)** is a clearly defined interface that specifies how one piece of software can request services or data from another. It defines which URLs (called **endpoints**) are available, what HTTP methods (GET, POST, PUT, DELETE) each endpoint accepts, what data format to send, and what response to expect back. Think of it as a contract between a client and a server: "If you send this request to this URL, I will respond with this data."

An **endpoint** is a specific URL on a server that performs a specific operation - for example, `/api/Students` is an endpoint that returns student data.

A **Web API** [1] is an API that is accessed over the internet using the HTTP protocol. Instead of returning HTML web pages (like a website does), a Web API returns structured **data** - typically in **JSON (JavaScript Object Notation)** [2] format. JSON is a lightweight, human-readable text format for representing data as key-value pairs, for example: `{"name": "John", "marks": 85}`. JSON has become the standard data exchange format for Web APIs because it is simple, compact, and supported by virtually every programming language.

Most modern Web APIs follow a design style called **REST (Representational State Transfer)** [3]. A **REST API** [3] (also called a RESTful API) is a Web API that uses standard HTTP methods to perform operations on resources:

* **GET** - Retrieve data (e.g., get a list of students)
* **POST** - Create new data (e.g., add a new student)
* **PUT** - Update existing data (e.g., change a student's marks)
* **DELETE** - Remove data (e.g., delete a student record)

Each resource (such as "students") has a base URL, and different HTTP methods on that URL perform different operations:

* `GET /api/Students` --> Returns a list of all students in JSON format
* `POST /api/Students` --> Creates a new student by sending JSON data in the request body
* `DELETE /api/Students/5` --> Deletes the student with ID 5

---

## Programming Language

You are free to **choose any programming language** of your interest to build this API (e.g., Python with Flask/FastAPI, Java with Spring Boot, Node.js with Express, etc.).

If you decide to use **C# with ASP.NET Core**, a starter project is provided for you with most endpoints already implemented. You only need to implement two missing endpoints (described in the Tasks section below).

---

## Getting Started with the C# Starter Project

If you choose C#, follow the steps below to set up your development environment.

### Step 1: Install Visual Studio Code

**Visual Studio Code (VS Code)** is a free, lightweight, and powerful code editor developed by Microsoft. It supports many programming languages and has a rich extension marketplace.

1. Go to the VS Code website [4]
2. Download the installer for your operating system (Windows, macOS, or Linux)
3. Run the installer and follow the on-screen instructions
4. After installation, open VS Code

#### Recommended Extensions

One of the most powerful features of VS Code is its **extension marketplace**. Extensions add language support, debuggers, code formatters, themes, and other tools directly into the editor. You can think of them as plugins that customize VS Code for the programming language or framework you are working with.

To install extensions, click the **Extensions icon** on the left sidebar (or press `Ctrl+Shift+X`), search for the extension name, and click **Install**.

Install the following extensions for this project:

* **C# Dev Kit** - by Microsoft. This is the essential extension for C# development. It provides IntelliSense (code auto-completion), syntax highlighting, debugging support, project management via the Solution Explorer panel, and the ability to run and debug your project directly from VS Code.
* **C#** - by Microsoft. This extension is automatically installed with C# Dev Kit and provides the underlying C# language server for code analysis and navigation.

### Step 2: Install Git

**Git** is a version control tool that developers use to track changes in their code and collaborate with others. A **repository** is a project folder tracked by Git. **GitHub** is a cloud platform that hosts Git repositories.

1. Go to the Git downloads page [5]
2. Download and install Git for your operating system
3. During installation, you can keep the default settings
4. After installation, verify it works by opening a terminal (in VS Code: `` Ctrl+` ``) and running:

```bash
git --version
```

You should see something like `git version 2.x.x`.

### Step 3: Clone the Repository

**Cloning** means downloading a copy of a remote repository to your local machine.

1. Open VS Code
2. Open the terminal (`` Ctrl+` `` or go to **Terminal > New Terminal**)
3. Navigate to the folder where you want to store the project:

```bash
cd C:\Users\YourName\Projects
```

1. Clone the repository:

```bash
git clone https://github.com/kashifsanadar/data2410-api-v1.git
```

See the starter project repository on your local computer.

1. Open the cloned project in VS Code:

```bash
cd data2410-api-v1
code .
```

VS Code will open with the project loaded. You should see the project files in the Explorer panel on the left.

### Step 4: Install .NET 10 SDK

The project is built with .NET 10. Download and install the SDK:

1. Go to the .NET 10 SDK download page [7]
2. Download the **.NET SDK** installer for your operating system
3. Run the installer
4. Verify by running in the terminal:

```bash
dotnet --version
```

> **Note for Linux/macOS users:** The C# starter project uses the Microsoft technology stack (.NET 10 and SQL Server) which is tailored for Windows. You are welcome to use your own technology stack - choose a programming language and database system that runs natively on your platform (e.g., Python with SQLite, Node.js with PostgreSQL, etc.).

---

## Database Setup

### Step 5: Install SQL Server and SSMS

Download and install **SQL Server 2025 Developer** edition - it is **free for development and educational use**.

1. Go to the SQL Server downloads page [8]
2. Scroll down and download the **Developer** edition
3. Run the installer and choose **Basic** installation
4. During setup, note down the **server name** (usually `localhost`) and configure **SQL Server Authentication** with a username and password

Install **SQL Server Management Studio (SSMS)** to interact with and manage your local SQL database visually. SSMS allows you to browse databases, run SQL queries, view table data, and more:

1. Go to the SSMS download page [9]
2. Download and install SSMS
3. After installation, open SSMS and connect to your local SQL Server using the server name and credentials you configured above

### Step 6: Configure the Connection String

The project needs a connection string to communicate with your local SQL Server. Open the file `appsettings.json` in the project root and add your connection string to the `ConnectionStrings` section:

```json
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

> **Important:** Replace `sa` and `YOUR_PASSWORD` with the SQL Server credentials you configured during installation. If your SQL Server uses a named instance, update the `Server` value accordingly, e.g. `Server=localhost\MSSQLSERVER`.

> **Note about Logging:** The `Logging` section controls how much diagnostic information the application writes to the console. The default settings are sufficient - you do not need to modify them.

**Important:** The database specified in the connection string (e.g., `StudentsDb`) must already exist on your SQL Server. Use SSMS to create an empty database with the matching name before running the project. The `Students` **table** is created automatically when the application starts - you do not need to create the table manually.

### Step 7: Run the Project

In the VS Code terminal, run:

```bash
dotnet restore
dotnet run
```

The API will start and you should see output indicating it is listening at `https://localhost:7010`.

---

## API Endpoints - Complete Description

The Student Management API provides the following endpoints. The base URL when running locally is `https://localhost:7010`.

### Student Data Model

Each student record has the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `id` | Integer | Unique identifier for the student |
| `name` | String | Student's full name |
| `course` | String | Course name (default: "DATA2410") |
| `marks` | Integer | Marks obtained (0-100) |
| `grade` | String (nullable) | Calculated grade (A, B, C, or D) |

---

### Endpoint 1: Get All Students

| | |
|---|---|
| **Method** | `GET` |
| **URL** | `/api/Students` |
| **Description** | Returns a list of all students in the database |
| **Request Body** | None |
| **Response** | JSON array of student objects |

**Example Response:**

```json
[
  {
    "id": 1,
    "name": "John Doe",
    "course": "DATA2410",
    "marks": 85,
    "grade": "B"
  },
  {
    "id": 2,
    "name": "Jane Smith",
    "course": "DATA2411",
    "marks": 92,
    "grade": "A"
  }
]
```

---

### Endpoint 2: Get Student by ID

| | |
|---|---|
| **Method** | `GET` |
| **URL** | `/api/Students/{id}` |
| **Description** | Returns a single student by their ID |
| **Request Body** | None |
| **Response** | A single student object, or `404 Not Found` if the student does not exist |

**Example:** `GET /api/Students/1`

---

### Endpoint 3: Create a Student

| | |
|---|---|
| **Method** | `POST` |
| **URL** | `/api/Students` |
| **Description** | Creates a new student record in the database |
| **Request Body** | JSON object with `name`, `course`, and `marks` |
| **Response** | The created student object with the assigned `id` |

**Example Request Body:**

```json
{
  "name": "John Doe",
  "course": "DATA2410",
  "marks": 85
}
```

---

### Endpoint 4: Update a Student

| | |
|---|---|
| **Method** | `PUT` |
| **URL** | `/api/Students/{id}` |
| **Description** | Updates an existing student's name, course, and marks |
| **Request Body** | JSON object with `name`, `course`, and `marks` |
| **Response** | `204 No Content` on success, or `404 Not Found` |

---

### Endpoint 5: Delete a Student

| | |
|---|---|
| **Method** | `DELETE` |
| **URL** | `/api/Students/{id}` |
| **Description** | Deletes a student by their ID |
| **Request Body** | None |
| **Response** | `204 No Content` on success, or `404 Not Found` |

---

### Endpoint 6: Calculate Grades **(TO BE IMPLEMENTED)**

| | |
|---|---|
| **Method** | `POST` |
| **URL** | `/api/Students/calculate-grades` |
| **Description** | Reads all students from the database, calculates a grade for each student based on their marks using the grading scale above, updates the grade in the database, and returns the list of students with their calculated grades |
| **Request Body** | None |
| **Response** | JSON array of all students with their updated grades |

**Expected Behavior:**

1. Read all students from the database
2. For each student, calculate the grade based on their marks
3. Update the `Grade` column in the database for each student
4. Return the complete list of students with their grades

**Example Response:**

```json
[
  {
    "id": 1,
    "name": "John Doe",
    "course": "DATA2410",
    "marks": 85,
    "grade": "B"
  },
  {
    "id": 2,
    "name": "Jane Smith",
    "course": "DATA2411",
    "marks": 92,
    "grade": "A"
  }
]
```

---

### Endpoint 7: Course-Wise Report **(TO BE IMPLEMENTED)**

| | |
|---|---|
| **Method** | `GET` |
| **URL** | `/api/Students/report` |
| **Description** | Generates a course-wise report of results. Groups students by course and returns statistics including total students, average marks, and grade distribution for each course |
| **Request Body** | None |
| **Response** | JSON array of course report objects |

**Expected Behavior:**

1. Query the database to group students by course
2. For each course, calculate: total number of students, average marks, and count of each grade (A, B, C, D)
3. Return the report

**Example Response:**

```json
[
  {
    "courseName": "DATA2410",
    "totalStudents": 3,
    "averageMarks": 78.33,
    "gradeDistribution": {
      "A": 1,
      "B": 1,
      "C": 1,
      "D": 0
    }
  },
  {
    "courseName": "DATA2411",
    "totalStudents": 2,
    "averageMarks": 80.0,
    "gradeDistribution": {
      "A": 1,
      "B": 0,
      "C": 1,
      "D": 0
    }
  }
]
```

---

### Endpoint 8: Health Check

| | |
|---|---|
| **Method** | `GET` |
| **URL** | `/health` |
| **Description** | Checks if the database connection is working |
| **Response** | JSON object with connection status |

---

## Tasks

### Task 1: Implement the `calculate-grades` Endpoint

Open the file `Controllers/StudentsController.cs` and locate the `CalculateGrades()` method. It currently contains a placeholder:

```csharp
[HttpPost("calculate-grades")]
public async Task<ActionResult<List<Student>>> CalculateGrades()
{
    var studentsWithGrade = new List<Student>();

    // Write code to calculate and update grades

    return studentsWithGrade;
}
```

Implement the logic to:

1. Connect to the database and read all students
2. Calculate the grade for each student based on their marks (use the `GetGrade()` helper method already provided in the controller at **lines 13-19**). You can call it as `GetGrade(student.Marks)` to get the grade for a student.
3. Update the `Grade` column in the database for each student
4. Return the list of all students with their calculated grades

### Task 2: Implement the `report` Endpoint

Locate the `Report()` method in the same file. It currently returns an empty response:

```csharp
[HttpGet("report")]
public async Task<IActionResult> Report()
{
    // Write code for the report generation logic.
    return Ok();
}
```

Implement the logic to:

1. Connect to the database and query students grouped by course
2. For each course, calculate: total students, average marks, and the count of each grade (A, B, C, D)
3. Return the course-wise report as shown in the example response above

**Hint:** You can use SQL `GROUP BY` with aggregate functions like `COUNT()`, `AVG()`, and `SUM(CASE WHEN ... END)` to generate the report in a single query.

---

## Live Deployed API

A fully working version of this API is deployed at the following base URL (referred to as `<BASE_URL>` below):

> **Base URL:** <https://data2410-api-v120260409134150-enauczfkapc9efat.norwayeast-01.azurewebsites.net>

You can use this deployed API as a reference to understand the expected behavior of the endpoints you need to implement. Append the following paths to the base URL and open them in your browser:

| Path | Description |
|------|-------------|
| `/` | Root - shows API status |
| `/api/Students` | Returns all students |
| `/api/Students/calculate-grades` | Calculate grades (use POST via Scalar/Postman) |
| `/api/Students/report` | Course-wise report of results |
| `/scalar/v1` | Interactive API documentation (Scalar) |
| `/health` | Database connectivity check |

### Using Scalar to Explore the API

**Scalar** is an interactive API documentation tool that is built into this project. It reads the API's OpenAPI specification and generates a beautiful, interactive web page where you can:

* **Browse** all available endpoints
* **Read** the description, request parameters, and response format for each endpoint
* **Send** test requests directly from the browser - no additional tools needed
* **View** the response data, status codes, and headers

To use Scalar:

1. Open the Scalar URL (either the deployed version or your local version at `https://localhost:7010/scalar/v1`)
2. You will see a list of all API endpoints on the left sidebar
3. Click on any endpoint to see its details
4. Click **"Test Request"** to send a request
5. For `POST` and `PUT` endpoints, you can enter the JSON body in the request editor
6. Click **"Send"** to execute the request and see the response

Alternatively, you can use **Postman** [10] - a popular API testing tool where you can create and save HTTP requests, organize them into collections, and view responses.

---

## Submission

### What to Submit

1. **Complete Source Code** - Submit your entire project as a **ZIP file**. Make sure the project compiles and runs without errors.

   **ZIP file naming convention:** Use the first name of each group member separated by underscores.

   **Example:** If your group members are Alice, Bob, Charlie, and Diana, name your ZIP file:

   ```
   Alice_Bob_Charlie_Diana.zip
   ```

2. **Short Report (PDF)** - A brief report (1-3 pages) containing:
   * **Screenshots** of Scalar or Postman showing your implemented endpoints in action:
     * A screenshot of the `POST /api/Students/calculate-grades` request and response
     * A screenshot of the `GET /api/Students/report` request and response

### Group Work

* You can work in groups of **maximum 4 students**
* Clearly mention the **names and student IDs** of all group members in the report
* Only **one submission per group** is required

---

## References

| # | Description | URL |
|---|-------------|-----|
| 1 | Web API - MDN Web Docs | <https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Server-side/First_steps/Client-Server_overview> |
| 2 | JSON - MDN Web Docs | <https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Scripting/JSON> |
| 3 | RESTful API Tutorial | <https://restfulapi.net/> |
| 4 | Visual Studio Code | <https://code.visualstudio.com/> |
| 5 | Git Downloads | <https://git-scm.com/downloads> |
| 6 | Starter Project Repository | <https://github.com/kashifsanadar/data2410-api-v1> |
| 7 | .NET 10 SDK Download | <https://dotnet.microsoft.com/download/dotnet/10.0> |
| 8 | SQL Server Downloads | <https://www.microsoft.com/en-us/sql-server/sql-server-downloads> |
| 9 | SQL Server Management Studio (SSMS) | <https://learn.microsoft.com/en-us/ssms/download-sql-server-management-studio-ssms> |
| 10 | Postman | <https://www.postman.com/downloads/> |

---

*Good luck!*
