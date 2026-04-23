-- Create the database if it doesn't exist.
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'StudentsDb')
BEGIN
    CREATE DATABASE StudentsDb;
END
-- "GO" is SQL Server-thing
---"Go" sends the previous block of SQL statements to the server and execute them.
GO

USE StudentsDb;
GO

-- Create the table if it doesn't exist (otherwise, TRUNCATE will result in an error)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Students')
BEGIN
    CREATE TABLE Students (
        Id INT PRIMARY KEY IDENTITY(1,1),
        Name NVARCHAR(100),
        Course NVARCHAR(50),
        Marks INT,
        Grade NVARCHAR(2)
    );
END
GO

TRUNCATE TABLE Students;
GO

INSERT INTO Students (Name, Course, Marks, Grade) VALUES
('Per Hansen', 'DATA2410', 95, NULL),
('Bjørn Olsen', 'DATA2410', 82, NULL),
('Anne Pedersen', 'DATA2410', 75, NULL),
('Mohammad Ahmed', 'DATA2410', 55, NULL),
('Sara Nguyen', 'DATA1300', 98, NULL),
('Amina Abdi', 'DATA1300', 88, NULL),
('Ole Nilsen', 'DATA1300', 75, NULL),
('Kjell Larsen', 'DATA1300', 45, NULL);
GO