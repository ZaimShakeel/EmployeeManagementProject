# CompanyZ Employee Management System

A Java-based command-line employee management system for Company Z, built with JDBC and MySQL. The app supports HR admin and employee workflows, including secure login, employee search, profile updates, salary management, and reporting.

## Features

- User authentication with role-based access
- HR admin menu for:
  - searching employees by last name, employee ID, employee number, date of birth, or SSN last 4
  - updating employee details
  - applying salary increases by range
  - generating pay reports by job title and division
  - viewing hires within a date range
- MySQL-backed data model with employees, divisions, job titles, salary history, users, and roles
- Stored procedure integration for employee updates

## Tech stack

- Java 17+ (or Java 11+)
- JDBC
- MySQL 8.0+
- Command-line interface

## Project structure

- `src/` – Java source files
- `CompanyZ_ems.sql` – MySQL schema and sample database setup
- `lib/` – external libraries and JDBC driver (if included)

## Setup

1. Install MySQL 8.0 or later.
2. Run `CompanyZ_ems.sql` to create the `companyz_ems` database and tables.
3. Update `src/DBConnection.java` with your MySQL username and password.
4. Ensure the MySQL JDBC driver is available on your classpath, for example:
   - `mysql-connector-java.jar`

## Build and run

From the project root:

```powershell
javac -d out src\*.java
java -cp out;lib\mysql-connector-java.jar Main
```

Or if the JDBC driver is on your global classpath:

```powershell
javac -d out src\*.java
java -cp out Main
```

## Usage

- Run the app and log in with an authorized user account.
- HR admins can search employees, update records, generate reports, and apply salary increases.
- Employees can log in to access their own information (depending on implementation details).

## Notes

- `AuthService` currently performs a simple password check and can be extended to use secure password hashing.
- The app assumes the MySQL database runs locally on `localhost:3306`.
- Customize the database credentials in `src/DBConnection.java` before running.

## Future improvements

- Add hashed password authentication and user registration
- Build a graphical or web UI
- Add audit logging and full RBAC control
- Improve input validation and error handling
