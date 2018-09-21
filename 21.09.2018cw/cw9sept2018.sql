/*use master
go
-- DB CREATION --
drop database University
go
create database University
go
use University
*/
go
create table Speciality
( 
spec_no INT PRIMARY KEY not null,
  spec_name varchar(50) not null
)

go
create table Faculty
(
fa_no INT PRIMARY KEY not null,
fa_name varchar(50) not null
)

go
create table Grade
(
grade_no varchar(50) not null,
value int not null,
constraint PK_Grade primary key(grade_no)
)

go
create table Subject
(
sub_no varchar(50) not null,
subject_name varchar(50) not null,
sub_pre_no varchar(50) null,
faculty_no int not null,
constraint PK_SubjectNO primary key(sub_no),
constraint FK_SubjectFaculty foreign key (faculty_no) references Faculty(fa_no) on update cascade on delete cascade,
constraint FK_SubjectSubject foreign key (sub_pre_no) references Subject(sub_no)
)

-- alter table Subject add constraint FK_SubjectSubject foreign key (sub_pre_no) references Subject(sub_no)

go
create table Student
(
stu_no varchar(50) not null,
stu_fname varchar(50) not null,
stu_lname varchar(50) not null,
course int,
spec_no int,
constraint PK_StuNO primary key(stu_no),
constraint FK_StudentSpeciality foreign key (spec_no) references Speciality(spec_no) on update cascade on delete cascade
)

go
create table Record 
(
rec_no int not null,
stu_no varchar(50) not null,
sub_no varchar(50) not null,
grade_no varchar(50) not null,
constraint PK_RecNo primary key(rec_no),
constraint FK_RecordGrade foreign key (grade_no) references Grade (grade_no) on update cascade  on delete cascade,
constraint FK_RecordStudent foreign key (stu_no) references Student(stu_no)  on update cascade  on delete cascade,
constraint FK_RecordSubject foreign key (sub_no) references Subject(sub_no)  on update cascade  on delete cascade
)
-- FILL DB--
go
insert into Grade values
('A', 4),
('B', 3),
('C', 2),
('D', 1)
go
insert into Speciality values
(11, 'Information Systems'),
(12, 'Computer Software')
go
insert into Faculty
values
(243, 'IT'),
(244, 'MATH')
go
insert into Student
values
('12BD09', 'Dean' , 'Winchester', 4, 11),
('13BD01', 'Blair' , 'Waldorf', 3, 12),
('11BD04', 'Natasha', 'Romanov', 2, 12),
('10BD02', 'Peter', 'Parker', 1, 11),
('11BD07', 'Tony', 'Stark', 2, 11)
go
insert into Subject values
('IT12', 'Data Structures', 'IT10', 243),
('MA10', 'Discrete Math', 'MA09', 244),
('MA09', 'Linear Algebra', NULL, 244),
('IT11', 'Web Technologies', NULL, 243),
('IT10', 'Algorithms', NULL, 243)
go
insert into Record values
(101, '12BD09', 'MA09', 'A'),
(102, '12BD09', 'IT11', 'B'),
(104, '12BD09', 'MA10', 'B'),
(105, '13BD01', 'IT12', 'C'),
(106, '13BD01', 'IT10', 'A'),
(107, '11BD04', 'MA09', 'C'),
(108, '10BD02', 'MA09', 'A'),
(109, '10BD02', 'IT11', 'C'),
(110, '11BD07', 'IT10', 'A')

-- TASKS --

/* 1.	Создайте представление, которое отображает имя, фамилию и предметы студента. Сделайте выборку из представления, где пререквизит предмета студента не пустой. */

go
create view t1 as
select s.stu_fname, s.stu_lname, j.subject_name
from Record r
join Student s on s.stu_no = r.stu_no
join Subject j on j.sub_no = r.sub_no
where j.sub_pre_no is not null
go
select * from t1
/*2.	Создайте представление, которое отображает номер, имя, фамилию и специальностьстудентов, чье имя заканчивается на ‘r’.Сделайте так, что бы нельзя было добавить студента, чье имя незаканчивается на ‘r’.*/
go
create view t2 as
select s.stu_fname, s.stu_lname, s.stu_no, l.spec_name
from Student s
join Speciality l on s.spec_no = l.spec_no
where s.stu_fname like '%r'
go
select * from t2

-- ALTER TABLE Student ADD CHECK (stu_fname like '%r')
/*3.	Создайте функцию, которая вернет наиболее востребованную специальность среди студентов.*/
go
create function t3()
returns varchar(50) as
begin
	declare @var varchar(50)
	select @var =
	(select top 1 l.spec_name from Student s
	join Speciality l on s.spec_no = l.spec_no
	group by l.spec_name
	order by COUNT(l.spec_name) desc)
	return @var
end
go
select dbo.t3()
go

/*4.	Создайте функцию для проверки числа студентов, у которых есть определенный предмет. Пусть это будет передаваемая переменная @exact_subject. Если у 2 студентов и больше есть этот предмет, верните сообщение ‘У @count_studentsесть этот @exact_subject’. Иначе,верните сообщение, где написано имя, фамилия и предметстудента у которого есть @exact_subject.*/
create function f4 (@exact_subject varchar(50))
returns varchar(150) as
begin
	declare @count_students int
	select @count_students =
		(select count(*) from Record r
		join Student s on r.stu_no = s.stu_no
		join Subject j on j.sub_no = r.sub_no
		where j.subject_name = @exact_subject)

	declare @r1 varchar(150)
	
	
	if @count_students >= 2
		begin
			select @r1 = @count_students + 'having this subject: ' + @exact_subject
		end
	else begin
			select @r1 =
				CAST((select s.stu_fname, s.stu_lname, j.subject_name
				from Record r
				join Student s on s.stu_no = r.stu_no
				join Subject j on j.sub_no = r.sub_no
				where j.subject_name = @exact_subject) as varchar(150))
		end
		return @r1
end
go

/*5.	Создайте хранимую процедуру, которая будет добавлять новую специальность, с входным параметром spec_name. Для spec_no пусть значение определяется автоматически на основе следующих манипуляций: достаньте spec_no последней специальности в таблице и заинкрементите это значение на количество знаков в spec_name соответствующего ему spec_no. Полученное значение и будет вашим spec_no для новой специальности.*/
go
create procedure p5 @spec_name varchar(50) as
insert into Speciality values
(cast((select top 1 spec_no from Speciality order by spec_no desc) as int) + cast((select top 1 LEN(spec_name) from Speciality order by spec_no desc) as int), @spec_name)

exec p5 'Bioinformatics'
exec p5 'Health informatics'
exec p5 'Business informatics'
exec p5 'Cheminformatics'
exec p5 'Disaster informatics'
exec p5 'Geoinformatics'
exec p5 'Information science'
exec p5 'Web sciences'
exec p5 'Management information system (MIS)'
exec p5 'Formative context'
exec p5 'Data processing'
exec p5 'Library science'

select * from Speciality

/*6.	Создайте функцию, которая вернет в виде таблицы имя, фамилию, предметы и оценки студентов, у которых есть возможность взять премет Data Structures.*/
go
alter function f6()
returns table as return
(select r.rec_no, s.stu_fname, s.stu_lname, j.subject_name, g.value from Record r
join Student s on s.stu_no = r.stu_no
join Subject j on j.sub_no = r.sub_no
join Grade g on g.grade_no = r.grade_no
where sub_pre_no = 'IT10')
go
select r.rec_no, s.stu_fname, s.stu_lname, j.subject_name, g.value from Record r
join Student s on s.stu_no = r.stu_no
join Subject j on j.sub_no = r.sub_no
join Grade g on g.grade_no = r.grade_no
where s.stu_fname in (select stu_fname from f6())
and s.stu_lname in (select stu_lname from f6())

go

/*7.	Создайте функцию, которая вернет имя студента с наибольшим количеством предметов.*/
go
alter function f7()
returns varchar(50) as
begin
	declare @v varchar(50)
	select @v = cast((select top 1 s.stu_fname from Record r
					join Student s on s.stu_no = r.stu_no
					group by s.stu_fname
					order by COUNT(s.stu_no) desc) as varchar(50))
	return @v
end
go
select dbo.f7() -- Dean

go
/*8.	Создайте функцию, которая возваращает предметы и количество их пререквизитов в виде таблицы. */

/*9.	Пусть оценка A соответствует числовому значению 4.00, B – 3.00, C – 2.00, D – 1.00. Написать хранимую процедуру, которая вернет таблицу, где перечислены имена студентов и среднее числовое значение оценки по всем предметам, которые он прошел.*/

/*10.	Пусть оценка A соответствует числовому значению 4.00, B – 3.00, C – 2.00, D – 1.00. Размер базовой стипендии (BASE_VALUE) составляет 20 000 тенге. В случае,если средний балл студента по всем предметам равен или больше 2.8, то стипендия вычисляется по формуле – BASE_VALUE + (BASE_VALUE / 10) * GRADES_AVERAGE. Пример: GRADES_AVERAGE = 3.1. Стипендия = 20 000 + (20 000 / 10) * 3.1. Написать хранимую процедуру, которая вернет список студентов (имена) тех студентов, которые могут получить стипендию и размер стипендии, который им полагается.*/

/*11.	Создайте триггер, который будет проводить аудит команды UPDATE, INSERT на колонку оценки в таблице оценок у студентов. Журнал изменений должен сохранять какая запись была изменена, старая оценка, новая оценка и дата изменения. */

/*12.	Добавьте колонку is_deleted  в таблицу оценок у студентов, пусть по дефолту все значения в этой колонке равны ‘NO’. Создайте триггер, который вместо удаления поставит значение ‘YES’ в колонку is_deleted, которая указывает, удалена ли запись.*/

/*13.	 Реализуйте функции из 7 и 8 пунктов на C#/CLR, скомпилируйте в сборку и создайте функцию.*/

select * from Faculty
select * from Grade
select * from Record
select * from Speciality
select * from Student
select * from Subject

