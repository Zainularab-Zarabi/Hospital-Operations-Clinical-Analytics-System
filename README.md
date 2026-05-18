# College Registration SQL Analysis

## Overview
This project demonstrates SQL Server database design and analytical querying using a college registration scenario. The database includes departments, students, instructors, courses, sections, and enrollments, then uses SQL queries to answer reporting-style questions about enrollment activity, course participation, department relationships, and student registration patterns.

The goal of this project is to show practical SQL skills that are useful for data analyst and business intelligence roles.

## Tools Used
- SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL

## Skills Demonstrated
- Relational database design
- Primary keys and foreign keys
- Table creation and sample data insertion
- INNER JOIN and LEFT JOIN
- Multi-table joins
- Aggregation with `COUNT`
- Subqueries and filtering
- Many-to-many relationship analysis
- Reporting-style SQL queries

## Database Tables
The project uses the following tables:

- **Departments** — department names and office locations
- **Students** — student details and declared major departments
- **Instructors** — instructor information and department assignments
- **Courses** — course details, department ownership, and credits
- **Sections** — course offerings by semester, year, instructor, and room
- **Enrollments** — student registrations and grades

## Analysis Questions Covered
The SQL script answers questions such as:

1. Which students are enrolled in which sections?
2. Which courses are connected to each department?
3. Which instructors teach which course sections?
4. Which students have no enrollments?
5. Which courses have the highest enrollment counts?
6. Which students are taking courses outside their major department?
7. How can joins be used to build reporting-style outputs across multiple related tables?

## Key Takeaways
- Multi-table joins are useful for combining normalized data into readable reports.
- LEFT JOIN queries help identify missing relationships, such as students with no enrollments.
- Aggregation queries help summarize course participation and enrollment activity.
- Comparing student major departments with course departments can reveal cross-department enrollment patterns.

## Files in This Repository
```text
sql/
  college_registration_analysis.sql
images/
  Add screenshots of query results here
docs/
  Optional notes or exported outputs
```

## How to Use
1. Open `sql/college_registration_analysis.sql` in SQL Server Management Studio.
2. Execute the full script.
3. Review the generated tables and query results.
4. Add screenshots of important query outputs to the `images/` folder if using this project in a portfolio.

## Portfolio Summary
SQL Server project demonstrating relational database design, joins, aggregation, and reporting-style analysis using a college registration database.
