USE master
GO

CREATE DATABASE Sampledb
GO

USE Sampledb
GO

CREATE TABLE Department
( 
dept_no VARCHAR(4) NOT NULL,
dept_name VARCHAR(30) NOT NULL,
location VARCHAR(30) NULL,
CONSTRAINT PK_dept_no PRIMARY KEY (dept_no)
)

INSERT INTO Department 
VALUES ('d1', 'Research', 'Dallas'), ('d2', 'Accounting', 'Seattle'), ('d3', 'Marketing', 'Dallas') 

CREATE TABLE Employee 
(
emp_no INTEGER NOT NULL,
emp_fname VARCHAR(20) NOT NULL,
emp_lname VARCHAR(20) NOT NULL,
dept_no VARCHAR(4) NOT NULL,
CONSTRAINT PK_emp_no PRIMARY KEY (emp_no),
CONSTRAINT FK_dept_no FOREIGN KEY (dept_no) REFERENCES department (dept_no) ON DELETE CASCADE ON UPDATE CASCADE
)

INSERT INTO Employee 
VALUES (25348, 'Matthew', 'Smith', 'd3'), (10102, 'Ann', 'Jones', 'd3'), (18316, 'John', 'Barrimore', 'd1'),
(29346, 'James', 'James', 'd2'), (9031, 'Elke', 'Hansel', 'd2'), (2581, 'Elsa', 'Bertoni', 'd2'),
(28559, 'Sybill', 'Moser', 'd1')

CREATE TABLE Project 
(
project_no VARCHAR(4) NOT NULL,
project_name VARCHAR(20) NOT NULL,
budget MONEY NULL,
CONSTRAINT PK_project_no PRIMARY KEY (project_no)
)

INSERT INTO Project 
VALUES ('p1', 'Apollo', 120000), ('p2', 'Gemini', 95000), ('p3', 'Mercury', 186500) 

CREATE TABLE Works_on
(
emp_no INTEGER NOT NULL,
project_no VARCHAR(4) NOT NULL,
job CHAR (40) NULL,
enter_date DATE NULL,
CONSTRAINT PK_emp_project PRIMARY KEY (emp_no, project_no),
CONSTRAINT FK_emp_no FOREIGN KEY (emp_no) REFERENCES employee (emp_no) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT FK_project_no FOREIGN KEY(project_no) REFERENCES project (project_no) ON DELETE CASCADE ON UPDATE CASCADE
)

INSERT INTO Works_on 
VALUES (10102, 'p1', 'Analyst', '2006.10.1'), (10102, 'p3', 'Manager', '2008.1.1'), (25348, 'p2', 'Clerk', '2007.2.15'), (18316, 'p2', NULL, '2007.6.1'),
(29346, 'p2', NULL, '2006.12.15'), (2581, 'p3', 'Analyst', '2007.10.15'), (9031, 'p1', 'Manager', '2007.4.15'),
(28559, 'p1', NULL, '2007.8.1'), (28559, 'p2', 'Clerk', '2008.2.1'), (9031, 'p3', 'Clerk', '2006.11.15'),
(29346, 'p1', 'Clerk', '2007.1.4')

CREATE TABLE Job
(
	job_no INT IDENTITY(1, 1) NOT NULL,
	job_name VARCHAR(30) NOT NULL
)

ALTER TABLE Job ADD CONSTRAINT PK_Job PRIMARY KEY(job_no)

INSERT Job(job_name) SELECT DISTINCT job FROM Works_on WHERE job IS NOT NULL

ALTER TABLE Works_on ADD job_no INT NULL
ALTER TABLE Works_on ADD CONSTRAINT FK_Works_on_job FOREIGN KEY(job_no)
REFERENCES Job(job_no) ON DELETE CASCADE ON UPDATE CASCADE

UPDATE Works_on
	SET job_no = (SELECT job_no FROM Job WHERE job_name = w.job)
FROM Works_on w

select * from Works_on

-- 10
go
alter function most_needed_jobs()
returns table
as return select j.job_name, count(w.emp_no) as q
from Job j
join Works_on w
on j.job_name = w.job
group by j.job_name

select * from most_needed_jobs() order by q desc

go 
alter function f8()
returns table
as return select /*top 1*/ e.emp_fname, sum(DATEDIFF(day, w.enter_date, CONVERT(date,GETDATE()))) as working_h from Employee e
join Works_on w
on e.emp_no = w.emp_no
group by e.emp_fname

select top 1 * from f8() order by working_h desc 
go
-- достает дни работы
select DATEDIFF(day, w.enter_date, CONVERT(date,GETDATE())) as days_in_work from Works_on w