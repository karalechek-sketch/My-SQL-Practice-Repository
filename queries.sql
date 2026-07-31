-- 1. Show the average salary of employees for each year up to 2005.
SELECT YEAR(from_date) AS report_year, AVG(salary) AS avg_salary
FROM salaries
GROUP BY report_year
HAVING report_year BETWEEN MIN(report_year) AND 2005
ORDER BY report_year;

-- 2. Report the average salary of employees in each department. Note: Calculate based on current salary and current department of employees.
SELECT dept_name, AVG(salary) AS avg_salary
FROM departments AS d
INNER JOIN dept_emp AS de ON (d.dept_no = de.dept_no)
INNER JOIN salaries s ON (s.emp_no = de.emp_no)
WHERE NOW() BETWEEN de.from_date AND de.to_date 
AND NOW() BETWEEN s.from_date AND s.to_date
GROUP BY d.dept_name;

-- 3. Show the average salary of employees in each department for each year.
SELECT dept_name, YEAR(s.from_date) AS report_year, AVG(salary) AS avg_salary
FROM departments AS d
INNER JOIN dept_emp AS de ON (d.dept_no = de.dept_no)
INNER JOIN salaries s ON (s.emp_no = de.emp_no)
GROUP BY d.dept_name, YEAR(s.from_date);

-- 4. Show departments that currently employ more than 15,000 people.
SELECT d.dept_name, COUNT(de.emp_no) AS num_of_emp
FROM departments AS d
INNER JOIN dept_emp AS de ON (d.dept_no = de.dept_no)
WHERE NOW() BETWEEN de.from_date AND de.to_date 
GROUP BY d.dept_name
HAVING num_of_emp > 15000;

-- 5. For the manager who has been working the longest, show their number, department, date of hire, and last name.
SELECT e.emp_no, d.dept_name, e.hire_date, e.last_name, TIMESTAMPDIFF (DAY, e.hire_date, CURRENT_DATE) AS days_in_company
FROM employees AS e
INNER JOIN dept_manager AS dm ON (e.emp_no = dm.emp_no)
INNER JOIN departments AS d ON (dm.dept_no = d.dept_no)
WHERE NOW() BETWEEN dm.from_date AND dm.to_date
ORDER BY days_in_company DESC
LIMIT 1;


-- 6. Show the top 10 active employees of the company with the largest difference between their salary and the average salary in their department.
WITH emp_salary AS (
SELECT sal.emp_no, de.dept_no, sal.salary
FROM salaries AS sal
INNER JOIN dept_emp AS de ON (sal.emp_no = de.emp_no)
WHERE  NOW() BETWEEN de.from_date AND de.to_date
AND NOW() BETWEEN sal.from_date AND sal.to_date
GROUP BY sal.emp_no, de.dept_no, sal.salary),

avg_dep_salary AS (
SELECT demp.dept_no, AVG(s.salary) AS avg_salary
FROM salaries AS s
INNER JOIN dept_emp AS demp ON (s.emp_no = demp.emp_no)
WHERE  NOW() BETWEEN demp.from_date AND demp.to_date
AND NOW() BETWEEN s.from_date AND s.to_date
GROUP BY demp.dept_no)

SELECT es.emp_no, es.dept_no, es.salary, ads.avg_salary, es.salary - ads.avg_salary AS salary_diff
FROM emp_salary AS es
INNER JOIN avg_dep_salary AS ads ON (es.dept_no = ads.dept_no)
ORDER BY salary_diff DESC
LIMIT 10;

/*7. For each department, show the second manager in order. It is necessary to display the department, the manager's last name and first name,
 the date the manager was hired, and the date when he became the department manager*/
 SELECT d.dept_name, e.last_name, e.first_name, e.hire_date, rank_man.from_date
 FROM (
 SELECT  emp_no, dept_no, from_date,  ROW_NUMBER() OVER (PARTITION BY dept_no ORDER BY from_date) as row_num
 FROM dept_manager) AS rank_man
 INNER JOIN departments AS d ON (d.dept_no = rank_man.dept_no)
 INNER JOIN employees AS e ON (e.emp_no = rank_man.emp_no)
 WHERE row_num = 2;

-- 1. Create a database for managing courses. The database should include the following tables:
CREATE DATABASE IF NOT EXISTS course_management; 
USE course_management; 
 
 /*students: student_no, teacher_no, course_no, student_name, email, birth_date.
- teachers: teacher_no, teacher_name, phone_no
- courses: course_no, course_name, start_date, end_date*/

CREATE TABLE IF NOT EXISTS teachers (
teacher_no INT AUTO_INCREMENT,
teacher_name VARCHAR (100) NOT NULL,
phone_no VARCHAR (15),
PRIMARY KEY (teacher_no)
);
DESC teachers;

CREATE TABLE IF NOT EXISTS courses(
course_no INT AUTO_INCREMENT,
course_name VARCHAR (100) NOT NULL, 
start_date DATE NOT NULL, 
end_date DATE NOT NULL,
PRIMARY KEY (course_no)
);
DESC courses;

CREATE TABLE IF NOT EXISTS students (
student_no INT AUTO_INCREMENT,
teacher_no INT NOT NULL,
course_no INT NOT NULL,
student_name VARCHAR (100) NOT NULL,
email VARCHAR (50),
birth_date DATE NOT NULL,
PRIMARY KEY (student_no),
FOREIGN KEY (teacher_no) REFERENCES teachers(teacher_no) 
ON DELETE CASCADE
ON UPDATE CASCADE,
FOREIGN KEY (course_no) REFERENCES courses(course_no)
ON DELETE CASCADE
ON UPDATE CASCADE
);
DESC students;

-- 2. Add any data (7-10 lines) to each table.
START TRANSACTION;

INSERT INTO teachers
(teacher_name, phone_no)
VALUES 
('Andrew Scott', '555-123-4567'),
('Rachel Green', '555-987-6543'),
('Leo Turner', '555-246-8101'),
('Laura Bennett', '555-333-1122'),
('Omar Williams', '555-666-7788'),
('Tom Jenkins', '555-909-0001'),
('Carlos Reyes', '555-202-3030'),
('Nina Patel', '555-404-5050'),
('Hannah Brooks', '555-707-8080'),
('Susan Blake', '555-101-1212');

SELECT *
FROM teachers;

INSERT INTO courses
(course_name, start_date, end_date)
VALUES
('Mathematics 101', '2025-09-01', '2026-01-15'),
('English Literature', '2025-10-11', '2026-02-24'),
('Biology Basics', '2025-11-10', '2026-05-06'),
('Computer Science Intro', '2025-09-15', '2026-03-21'),
('Physics I', '2025-11-25', '2026-06-14'),
('Chemistry I', '2025-10-12', '2026-03-15'),
('Art & Design', '2025-09-08', '2026-07-21'),
('Music Theory', '2025-09-15', '2026-04-29'),
('Economics Basics', '2025-10-18', '2026-05-31'),
('World History', '2025-11-01', '2026-04-28');

SELECT *
FROM courses;

INSERT INTO students
(teacher_no, course_no, student_name, email, birth_date)
VALUES
(1, 1, 'Alice Johnson', 'alice.johnson@example.com', '2004-03-12'),
(2 , 2 , 'Brian Smith', 'brian.smith@example.com', '2005-01-18'),
(3 , 5 , 'Chloe Martinez', 'chloe.m@example.com', '2004-11-30'),
(7 , 9 , 'Daniel Lee', 'daniel.lee@example.com', '2003-05-09'),
(8 , 10 , 'Emily Davis', 'emily.davis@example.com', '2004-09-25'),
(3 , 3 , 'Felix Nguyen', 'felix.n@example.com', '2005-02-13'),
(1 , 4 , 'Grace Kim', 'grace.kim@example.com', '2004-06-15'),
(4 , 5 , 'Henry Adams', 'henry.adams@example.com', '2003-12-05'),
(5 , 6 , 'Irene Zhao', 'irene.zhao@example.com', '2003-07-22'),
(10 , 7 , 'Jack Wilson', 'jack.wilson@example.com', '2005-08-29');

SELECT *
FROM students;

COMMIT;
-- 3.  For each teacher, show the number of students with whom he or she has worked.
SELECT t.teacher_name, COUNT(student_no) AS num_of_students
FROM students AS s
RIGHT JOIN teachers AS t ON (t.teacher_no = s.teacher_no)
GROUP BY t.teacher_name;

-- 4. Specifically, make 3 duplicates in the students table (add 3 more identical rows).  
INSERT INTO students (teacher_no, course_no, student_name, email, birth_date)
VALUES
(8, 10, 'Emily Davis', 'emily.davis@example.com', '2004-09-25'),
(8, 10, 'Emily Davis', 'emily.davis@example.com', '2004-09-25'),
(8, 10, 'Emily Davis', 'emily.davis@example.com', '2004-09-25');

-- 5. Write a query that will display duplicate rows in the students table.
WITH ranked_students AS (
  SELECT student_no, teacher_no, course_no, student_name, email, birth_date,
    ROW_NUMBER() OVER (PARTITION BY teacher_no, course_no, student_name, email, birth_date ORDER BY student_no) AS rn
  FROM students
)
SELECT *
FROM students
WHERE student_no IN (
  SELECT student_no
  FROM ranked_students
  WHERE rn > 1
);
