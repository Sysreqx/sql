USE Sampledb

SELECT*FROM Department
ALTERVIEW v_dept
	ASSELECT dept_no, dept_name,locationFROM Department
	WHERElocationISNOTNULL
	WITHCHECKOPTION

SELECT*FROM v_dept
SELECT*FROM Department
INSERTINTO v_dept VALUES ('d6','Logist','Moskow')

/*1.	Создайте представление, которое отображает номер, 
имя и фамилию сотрудника. Сделайте выборку из представления, 
где фамилия сотрудника начинается на ‘B’.*/
GO
CREATEVIEW v_1
	ASSELECT f.emp_no,f.emp_lname,f.emp_fname from Employee f
GO
	SELECT*FROM v_1 where emp_lname like'B%'

/*2.	Создайте представление, 
которое отображает номер, имя и 
название департамента сотрудника. 
Сделайте выборку из представления, 
где не будет сотрудников из департамента ‘Accounting’.
*/

CREATEVIEW v_2
	ASSELECT f.emp_no,f.emp_fname,dept_name FROM Employee f
	join Department ON f.dept_no= Department.dept_no

	SELECT*FROM v_2 WHERE dept_name <>'Accounting'

/*3.Создайте представление, которое отображает номер, имя, 
фамилию и номер департамента сотрудников, 
чье имя не начинатся на ‘A’.
Добавьте нового сотрудника в это представление, 
так, чтобы его имя начиналось на ‘A’. Проверьте базовую 
таблицу Employee, были ли внесены ваши изменения?
*/
go
alterview v_3 
asselect e.emp_no, e.emp_fname, e.emp_lname, e.dept_no
from Employee e
where e.emp_fname notlike'A%'
go
insertinto v_3 values (23523,'Abba','ADfs','d4')
select*from Employee
select*from v_3
go
/* 4.	Измените имя сотрудника с ‘Matthew’ на ‘Tom’
 из представления, которое вы создали в пункте 3 
 Проверьте базовую таблицу Employee, 
 были ли внесены ваши изменения?*/
go
update v_3
	set emp_fname ='Tom'
	where emp_fname ='Matthew'
go

select*from v_3

/*5.Измените представление из пункта 3, д
обавив WITH CHECK OPTION. 
Попробуйте добавить еще одного сотрудника с именем на ‘A’. 
Проверьте базовую таблицу Employee, 
были ли внесены ваши изменения?
*/

go
alterview v_3 
asselect e.emp_no, e.emp_fname, e.emp_lname, e.dept_no
from Employee e
where e.emp_fname notlike'A%'
WITHCHECKOPTION
go

insertinto v_3 values (54545,'GDGJHD','ADfs','d4')
select*from Employee
SELECT*FROM v_3

DELETEFROM v_3 WHERE emp_no = 54545

CREATETABLE tv(
	Id INTIDENTITY(2, 4)
)


SELECT*FROM Works_on
SELECT*FROM Employee

DECLARE @name VARCHAR(20)
SELECT @name =  emp_fname FROM Employee WHERE emp_fname ='Elsa'
IF ((SELECTCOUNT(*)
		FROM Works_on w
		JOIN Employee e ON w.emp_no = e.emp_no  
		GROUPBY e.emp_no, e.emp_fname
		HAVING e.emp_fname = @name)= 1)
	BEGIN
		PRINT @name +' works on project'



	END
ELSE
	BEGIN
		PRINT @name +' works on many project'
	END
GO


SELECT*FROM Project


DECLARE @premium MONEY, @limit MONEY
SET @premium = 10000
SET @limit = 500000
WHILE(SELECTSUM(budget)
		FROM Project)< @limit - 3*@premium
	BEGIN
		UPDATE Project SET budget = budget + @premium
	END
GO

SELECTSUM(budget)FROM Project


/* 1.Создайте пакет для проверки числа работников, 
которые трудятся над проектом ‘p2’. 
Если их больше 3, выведите сообщение 
‘Над проектом ‘p2’ работает большая команда’. 
Иначе, выведите сообщение ‘Над проектом ‘p2’ работают:’ 
и выведите emp_fname, emp_lname, dept_name и job 
всех работников которые работают над проектом ‘p2’.*/
select*from Works_on


IF (SELECTCOUNT(*)FROM Works_on w groupby w.project_no having w.project_no ='p2')>3
	BEGIN
		PRINT'MOre p2'
	END
ELSE
	BEGIN
		select e.emp_fname,e.emp_lname,d.dept_no from Employee e
		innerjoin Department d on d.dept_no=e.dept_no
		innerjoin Works_on w on w.emp_no=e.emp_no
		where w.project_no='p2'
	END
GO


/*3.	Создайте пакет для вставки 3000 строк в таблицу employee. 
Значения столбца emp_no должны быть однозначными в диапазоне от 1 до 3000. 
Всем ячейкам столбцов emp_lname, emp_fname и dept_no присваива
ются значения "Jane", "Smith" и "d1" соответственно.*/

declare @cnt integer;
set @cnt = 0;
declare @cnt_emp_no integer;
set @cnt_emp_no = 5000;

while (@cnt < 3000)
	begin
		insertinto Employee values (RAND()*(1000000000-0+1)+0,'Jane','Smith','d1')
		set @cnt = @cnt + 1
	end


	deletefrom Employee where emp_fname ='Jane'

	selectcount(*)from Employee where emp_fname ='Jane'
