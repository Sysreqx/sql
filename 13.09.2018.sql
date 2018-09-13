use master 

create table job 
( 
job_no int identity(1,1) not null, 
job_name varchar(30) not null 
) 

alter table job add constraint pk_job primary key (job_no) 

insert job(job_name) select distinct job 
from works_on where job is not null 

alter table works_on add job_no int null 

update w 
set job_no =(select job_no from job where job_name = w.job) 
from Works_on w 

alter table works_on add constraint Fk_works_onjob 
foreign key(job_no) references job(job_no) 
on delete cascade on update cascade 


select * from Works_on 

go 
create function f_costs(@percent int = 10) 
returns float 
begin 
declare @sum float, @costs float 
select @sum = sum(budget) from Project 
set @costs = @sum * @percent/100 
return @costs 
end 

select sum(budget) from Project 
select budget from Project where budget > dbo.f_costs(20) 
select dbo.f_costs(default) 

go 
create function f_table() 
returns table 
as return select p.project_name, w.emp_no from Project p 
join Works_on w on w.project_no = p.project_no 

select * from dbo.f_table() 

select * from Department 
insert into Department values ('d101', 'Research1', 'Dallas') 
,('d102', 'Accounting2', 'Dallas') 
,('d103', 'Marketing3', 'Seattle') 
,('d104', 'Accounting4', 'Seattle') 
,('d105', 'Research5', 'Dallas') 

go 
alter function is_has_dep(@city_n varchar(20)) 
returns bit 
begin 
if(select count(*) from Department where Department.location = @city_n) >= 1 
return 1; 
return 0; 
end 

select dbo.is_has_dep('Seattle'); 

go 
create function how_much_dep(@city_n varchar(20)) 
returns int 
begin 
declare @r_i int 
select @r_i = count(*) from Department where location = @city_n 
return @r_i; 
end 

select dbo.how_much_dep('Seattle'); 

go 
create function dep_names_by_city(@city_n varchar(20)) 
returns table 
as return select d.dept_name from Department d where location = @city_n 

select * from dbo.dep_names_by_city('Seattle') 
select * from Department 


/* 5. Написать функцию F(), которая возвращает список городов, в которых 2 и более департамента. */ 
go 
alter function dep_more_than2() 
returns table 
as return select d.location from Department d group by d.location having count(dept_name) >= 2 

select * from dbo.dep_more_than2() 

/* 6. Написать функцию F(), которая вернет список департаментов отсортированных по количеству сотрудников в них. */ 
go 
create function list_of_dep() 
returns table 
as return select d.dept_name, count(e.emp_no) as quantity_of_emp 
from Department d 
join Employee e 
on e.dept_no = d.dept_no 
group by dept_name 

select * from dbo.list_of_dep() order by quantity_of_emp 

/* 7. Написать функцию F(), которая вернет сотрудника с наибольшей продолжительностью работы в каком-либо из проектов.*/ 

go 
create function most_exp_emp() 
returns varchar(20) 
begin 
declare @n varchar(20) 
select @n = e.emp_fname 
from Works_on w join Employee e 
on e.emp_no = w.emp_no 
where w.enter_date = (select min(enter_date) from Works_on) 
return @n 
end 

select dbo.most_exp_emp() 

/* 9. Написать функцию F(), которая вернет сотрудника, который принял участие в наибольшем количестве проектов. */ 

go 
create function most_exp_emp_in_proj() 
returns varchar(20) 
begin 
declare @n varchar(20) 
select @n = e.emp_fname 
from Works_on w join Employee e 
on e.emp_no = w.emp_no 
group by e.emp_fname 
having count(*) = 
( 
select top 1 count(*) as q 
from Works_on o 
group by o.emp_no 
order by q desc 
) 
return @n 
end 

select dbo.most_exp_emp()
 
============
 
use NORTHWND 

go 
create function f1(@emp_id int) 
returns bit 
begin 
if (select count(*) from Employees e join Orders o on o.EmployeeID = e.EmployeeID 
where @emp_id in (select EmployeeID from Orders)) > 100 
return 1; 
return 0; 
end 

select dbo.f1('1') 

select count(*) from Employees e join Orders o on o.EmployeeID = e.EmployeeID 
where e.EmployeeID in (select EmployeeID from Orders) 

select * from Customers 

/*ssssssssssssssssssssss*/ 

go 
create function f2() 
returns table 
as return select ReportsTo, FirstName from Employees e 
where e.EmployeeID in ( select distinct EmployeeID from Employees) 

select * from dbo.f2() 

select countReportsTo, FirstName from Employees e 
where e.EmployeeID in ( select distinct EmployeeID from Employees) 
order by e.ReportsTo desc
 
===============
 
USE master 
GO 

CREATE DATABASE Sampledb 

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