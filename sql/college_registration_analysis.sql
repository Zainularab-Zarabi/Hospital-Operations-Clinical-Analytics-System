/*
Project: College Registration SQL Analysis
Purpose: Portfolio-ready SQL Server project demonstrating relational database design,
joins, subqueries, aggregation, and reporting-style analysis.

How to run:
1. Open in SQL Server Management Studio (SSMS).
2. Run the script from top to bottom.
3. Review the result sets for each analysis question.

Note: This project uses sample academic data for demonstration purposes.
*/

CREATE DATABASE CollegeRegistrationDB;
GO

USE CollegeRegistrationDB;
GO

-- Departments table
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    OfficeLocation VARCHAR(100)
);

-- Students table
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    MajorDepartmentID INT,
    EnrollmentYear INT,
    Email VARCHAR(100),

    -- Foreign Key
    FOREIGN KEY (MajorDepartmentID) 
        REFERENCES Departments(DepartmentID)
);
-- Instructors table
CREATE TABLE Instructors (
    InstructorID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DepartmentID INT,
    HireDate DATE,

    FOREIGN KEY (DepartmentID) 
        REFERENCES Departments(DepartmentID)
);
-- Courses table
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseCode VARCHAR(20) NOT NULL,
    CourseTitle VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    Credits INT NOT NULL,

    FOREIGN KEY (DepartmentID) 
        REFERENCES Departments(DepartmentID)
);
-- Sections table
CREATE TABLE Sections (
    SectionID INT PRIMARY KEY,
    CourseID INT NOT NULL,
    InstructorID INT,
    Semester VARCHAR(20) NOT NULL,
    YearOffered INT NOT NULL,
    Room VARCHAR(20),

    FOREIGN KEY (CourseID) 
        REFERENCES Courses(CourseID),

    FOREIGN KEY (InstructorID) 
        REFERENCES Instructors(InstructorID)
);
-- Enrollments table
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentID INT NOT NULL,
    SectionID INT NOT NULL,
    EnrollmentDate DATE,
    Grade VARCHAR(2),

    FOREIGN KEY (StudentID) 
        REFERENCES Students(StudentID),

    FOREIGN KEY (SectionID) 
        REFERENCES Sections(SectionID)
);
INSERT INTO Departments VALUES
(1, 'Computer Science', 'B201'),
(2, 'Business', 'C110'),
(3, 'Mathematics', 'A315'),
(4, 'English', 'D220');

INSERT INTO Students VALUES
(101, 'Ali', 'Hassan', 1, 2023, 'ali.hassan@college.edu'),
(102, 'Sara', 'Khan', 2, 2022, 'sara.khan@college.edu'),
(103, 'Michael', 'Smith', 1, 2021, 'michael.smith@college.edu'),
(104, 'Lina', 'Chen', 3, 2023, 'lina.chen@college.edu'),
(105, 'Omar', 'Farah', 4, 2024, 'omar.farah@college.edu'),
(106, 'Nora', 'Ahmed', NULL, 2024, 'nora.ahmed@college.edu');

INSERT INTO Instructors VALUES
(201, 'John', 'Miller', 1, '2018-08-15'),
(202, 'Emily', 'Clark', 2, '2019-01-10'),
(203, 'David', 'Lee', 3, '2016-09-01'),
(204, 'Sophia', 'Brown', 4, '2020-02-20'),
(205, 'James', 'Wilson', 1, '2021-06-01');

INSERT INTO Courses VALUES
(301, 'CST101', 'Introduction to Databases', 1, 3),
(302, 'CST220', 'Advanced SQL', 1, 4),
(303, 'BUS150', 'Principles of Management', 2, 3),
(304, 'MAT200', 'Statistics I', 3, 3),
(305, 'ENG110', 'Academic Writing', 4, 3),
(306, 'CST330', 'Data Warehousing', 1, 4);

INSERT INTO Sections VALUES
(401, 301, 201, 'Fall', 2025, 'R101'),
(402, 302, 205, 'Fall', 2025, 'R102'),
(403, 303, 202, 'Fall', 2025, 'B210'),
(404, 304, 203, 'Fall', 2025, 'M120'),
(405, 305, 204, 'Fall', 2025, 'E115'),
(406, 306, NULL, 'Fall', 2025, 'R103'),
(407, 301, 201, 'Winter', 2026, 'R101');

INSERT INTO Enrollments VALUES
(501, 101, 401, '2025-08-20', 'A'),
(502, 101, 402, '2025-08-20', 'B+'),
(503, 102, 403, '2025-08-21', 'A-'),
(504, 103, 401, '2025-08-22', 'B'),
(505, 103, 404, '2025-08-22', 'A'),
(506, 104, 404, '2025-08-23', 'A-'),
(507, 105, 405, '2025-08-24', 'B+'),
(508, 102, 401, '2025-08-25', 'B'),
(509, 106, 406, '2025-08-26', NULL);

SELECT * FROM Instructors;

/*Task 1: Basic Inner Join
Write a query to list all enrollments showing student full name, section ID, and grade.
Expected columns: StudentID, StudentName, SectionID, Grade.*/

SELECT 
    s.StudentID,
    s.FirstName + ' ' + s.LastName AS StudentName,   -- create full name
    e.SectionID,                      
    e.Grade
FROM Students s
INNER JOIN Enrollments e                         --Used IJ because only enrolled students are needed
    ON s.StudentID = e.StudentID;


/*Task 2: Join Across Multiple Tables
Write a query to show which students are enrolled in which course titles. Join Students, Enrollments,
Sections, and Courses. Expected columns: StudentName, CourseCode, CourseTitle, Semester, YearOffered.*/

SELECT
    s.FirstName + ' ' + s.LastName AS StudentName,
    c.CourseCode,
    c.CourseTitle,
    sec.Semester,
    sec.YearOffered
FROM Students s                  -- We follow relation chain:Students - Enrollments - Sections - Courses
INNER JOIN Enrollments e 
    ON s.StudentID = e.StudentID
INNER JOIN Sections sec 
    ON e.SectionID = sec.SectionID
INNER JOIN Courses c 
    ON sec.CourseID = c.CourseID;

/*Task 3: Join with Department Lookup
List all students and their major department name. Include students even if they 
do not yet have a major. Expected columns: StudentID, StudentName, DepartmentName.*/

SELECT
    s.StudentID,
    s.FirstName + ' ' + s.LastName AS StudentName,
    d.DepartmentName
FROM Students s
LEFT JOIN Departments d
    ON s.MajorDepartmentID = d.DepartmentID;

/*Task 4: Left Join to Find Missing Relationships
Find all course sections that do not yet have an instructor assigned. Expected columns: 
SectionID, CourseTitle, Semester, YearOffered.*/

SELECT
    sec.SectionID,
    c.CourseTitle,
    sec.Semester,
    sec.YearOffered
FROM Sections sec
LEFT JOIN Courses c
    ON sec.CourseID = c.CourseID
WHERE sec.InstructorID IS NULL;

/*Task 5: Multi-Join Reporting Query
Create a report showing course title, section ID, instructor name, and number of enrolled students.
Include sections with zero students. Expected columns: CourseTitle, SectionID, InstructorName, StudentCount.*/

SELECT
    c.CourseTitle,
    sec.SectionID,
    i.FirstName + ' ' + i.LastName AS InstructorName,
    COUNT(e.StudentID) AS StudentCount
FROM Sections sec
LEFT JOIN Courses c
    ON sec.CourseID = c.CourseID
LEFT JOIN Instructors i
    ON sec.InstructorID = i.InstructorID
LEFT JOIN Enrollments e
    ON sec.SectionID = e.SectionID
GROUP BY
    c.CourseTitle,
    sec.SectionID,
    i.FirstName,
    i.LastName;

   /* Task 6: Self-Join
Using a self-join on Students, find pairs of students in the same major department.
Do not pair a student with themselves and do not show duplicate reversed pairs.
Expected columns: Student1, Student2, MajorDepartmentID.*/

SELECT
    s1.FirstName + ' ' + s1.LastName AS Student1,
    s2.FirstName + ' ' + s2.LastName AS Student2,
    s1.MajorDepartmentID
FROM Students s1
INNER JOIN Students s2
    ON s1.MajorDepartmentID = s2.MajorDepartmentID
    AND s1.StudentID < s2.StudentID;               -- avoid duplicates

/*Task 7: Many-to-Many Join Analysis
Find all instructors and the courses they teach using Instructors, Sections, and Courses.
Expected columns: InstructorName, CourseCode, CourseTitle, Semester, YearOffered.*/

SELECT
    i.FirstName + ' ' + i.LastName AS InstructorName,
    c.CourseCode,
    c.CourseTitle,
    sec.Semester,
    sec.YearOffered
FROM Instructors i
INNER JOIN Sections sec                             -- Instruction - section - courses ...
    ON i.InstructorID = sec.InstructorID
INNER JOIN Courses c
    ON sec.CourseID = c.CourseID;

/*Task 8: Advanced Join with Aggregation
Find the number of students enrolled in each department’s courses. 
This is based on the department that owns the course, not the student major.
Expected columns: DepartmentName, TotalEnrollments.*/

SELECT
    d.DepartmentName,
    COUNT(e.EnrollmentID) AS TotalEnrollments
FROM Departments d
LEFT JOIN Courses c                                -- Departments - Courses - Sections - Enrollments...
    ON d.DepartmentID = c.DepartmentID
LEFT JOIN Sections sec
    ON c.CourseID = sec.CourseID
LEFT JOIN Enrollments e
    ON sec.SectionID = e.SectionID
GROUP BY d.DepartmentName;

/*Task 9: Students Without Enrollments
Write a query to find students who are not enrolled in any section. 
Expected columns: StudentID, StudentName.*/

SELECT
    s.StudentID,
    s.FirstName + ' ' + s.LastName AS StudentName
FROM Students s                                       -- students not enrolled in any section...
LEFT JOIN Enrollments e
    ON s.StudentID = e.StudentID
WHERE e.StudentID IS NULL;


/*Task 10: Advanced Challenge
Find students who are taking a course outside their major department.
For each enrollment, compare the student’s major department and the course’s department.
Ignore students with no declared major. Expected columns:
StudentName, MajorDepartment, CourseCode, CourseTitle, CourseDepartment.*/

SELECT
    s.FirstName + ' ' + s.LastName AS StudentName,
    d1.DepartmentName AS MajorDepartment,
    c.CourseCode,
    c.CourseTitle,
    d2.DepartmentName AS CourseDepartment            -- students taking courses outside their major...
FROM Students s
INNER JOIN Enrollments e
    ON s.StudentID = e.StudentID
INNER JOIN Sections sec
    ON e.SectionID = sec.SectionID
INNER JOIN Courses c
    ON sec.CourseID = c.CourseID
INNER JOIN Departments d1
    ON s.MajorDepartmentID = d1.DepartmentID
INNER JOIN Departments d2
    ON c.DepartmentID = d2.DepartmentID
WHERE s.MajorDepartmentID <> c.DepartmentID;

