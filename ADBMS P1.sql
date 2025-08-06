CREATE DATABASE IF NOT EXISTS university;
USE university;

-- (Part A): Creating Department and Course tables 
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) UNIQUE
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
);

-- Part B: Inserting data into the created tables
INSERT INTO Departments (dept_id, dept_name) VALUES
(1, 'Computer Science'),
(2, 'Electrical'),
(3, 'Mechanical'),
(4, 'Civil'),
(5, 'Electronics');

INSERT INTO Courses (course_id, course_name, dept_id) VALUES
(101, 'DBMS', 1),
(102, 'Operating Systems', 1),
(103, 'Data Structures', 1),
(104, 'Power Systems', 2),
(105, 'Digital Circuits', 2),
(106, 'Control Systems', 2),
(107, 'Thermodynamics', 3),
(108, 'Fluid Mechanics', 3),
(109, 'Structural Engineering', 4),
(110, 'Surveying', 4),
(111, 'Embedded Systems', 5),
(112, 'VLSI Design', 5);

-- Part C: Retrieving departments using subquery
SELECT dept_name
FROM Departments
WHERE dept_id IN (
    SELECT dept_id
    FROM Courses
    GROUP BY dept_id
    HAVING COUNT(course_id) > 2
);

-- Part D: Granting SELECT access on Courses
-- These commands require administrative privileges.
CREATE USER 'viewer_user'@'localhost' IDENTIFIED BY 'adbms';
GRANT SELECT ON university.Courses TO 'viewer_user'@'localhost';
FLUSH PRIVILEGES;

SHOW GRANTS FOR 'viewer_user'@'localhost';