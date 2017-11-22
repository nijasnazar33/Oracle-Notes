-- Simple natural join between DEPT and EMP tables based on the primary key of the DEPT table DEPTNO, and the DEPTNO foreign key in the EMP table.
select ename, dname, job, empno, hiredate, loc  
from emp, dept  
where emp.deptno = dept.deptno  
order by ename;

-------------------------------------------------------------------------------------------------------------
-- The GROUP BY clause in the SQL statement allows aggregate functions of non grouped columns.  
--The join is an inner join thus departments with no employees are not displayed.
select dname, count(*) count_of_employees
from dept, emp
where dept.deptno = emp.deptno
group by DNAME
order by 2 desc


-------------------------------------------------------------------------------------------------------------
--Name and salary of the employee with the third hightest salary.
select ename, sal
  from emp
 where sal = (
          select max(sal)
            from emp
           where sal < (
                    select max(sal)
                      from emp
                     where sal < (
                              select max(sal)
                                from emp
                            )
                    )
        );

		
-------------------------------------------------------------------------------------------------------------
--Dept, Name and Salary of the employees having max salary in each department
select m.deptno,
       e.ename,
       m.max_sal
  from emp e,
       (
       select deptno,
              max(sal) max_sal
         from emp
     group by deptno) m
 where e.sal = m.max_sal
order by m.deptno;


-------------------------------------------------------------------------------------------------------------
--Employees having salary less than the average salary in their department
select m.deptno,
       e.ename,
       e.sal,
       to_char(m.avg_sal, '999,999.99')
  from emp e,
       (select deptno,
               avg(sal) avg_sal
          from emp
      group by deptno) m
 where e.sal < m.avg_sal
   and e.deptno = m.deptno
order by m.deptno, e.sal desc;


-------------------------------------------------------------------------------------------------------------
--Deptno and count of employees making more than 2000 in those departments that has more than 5 employees.
select e.deptno,
          count(*)
  from emp e
where deptno in (
                       select deptno
					     from emp
				   group by deptno
				      having count(empno)>4)
   and sal > 2000
group by e.deptno
;


-------------------------------------------------------------------------------------------------------------
--Updating age for each employee using bulk collect and forall and assosicative array
declare
	lv_age number;
	type emp_age_rt is record(empno emp.empno%type, age emp.age%type);
	type emp_age_ntt is table of emp_age_rt index by pls_integer;
	lv_emp_age_nt emp_age_ntt;
begin
	select empno,age bulk collect into lv_emp_age_nt from emp;
	for indx in lv_emp_age_nt.FIRST..lv_emp_age_nt.LAST
	loop
		lv_age := to_number(substr(to_char(lv_emp_age_nt(indx).empno),3));
		if lv_age <20
		then
			lv_emp_age_nt(indx).age := lv_age +20;
		elsif lv_age > 70
		then
			lv_emp_age_nt(indx).age := lv_age -30;
		else
			lv_emp_age_nt(indx).age := lv_age;
		end if;
	end loop;

forall indx in lv_emp_age_nt.FIRST..lv_emp_age_nt.LAST
    update emp set age = lv_emp_age_nt(indx).age
    where empno = lv_emp_age_nt(indx).empno;

commit;

exception
when others then
    dbms_output.put_line(sqlerrm);
end;


-------------------------------------------------------------------------------------------------------------
--Updating age for each employee without using bulk collect, but with nested table(cursor for loop and manual looping)
declare

    cursor emp_cur
	is
	select empno from emp;

    lv_age number;
    type emp_age_rt is record(empno emp.empno%type, age emp.age%type);
    type emp_age_ntt is table of emp_age_rt;
    lv_emp_age_nt emp_age_ntt := emp_age_ntt();
    emp_rec emp_cur%rowtype;

begin

	-- if bulk collect is used no need for initialization and extention of the nested table
	-- select empno,age bulk collect into lv_emp_age_nt from emp;

    open emp_cur;
    loop
        FETCH emp_cur into emp_rec;
        lv_emp_age_nt.EXTEND;
        lv_emp_age_nt(lv_emp_age_nt.LAST).empno := emp_rec.empno;
        exit when emp_cur%NOTFOUND;
    end loop;
    close emp_cur;
    -- for emp_rec in emp_cur
    -- loop
    --     lv_emp_age_nt.EXTEND;
    --     lv_emp_age_nt(lv_emp_age_nt.LAST).empno := emp_rec.empno;
    -- end loop;

for indx in lv_emp_age_nt.FIRST..lv_emp_age_nt.LAST
loop
    lv_age := to_number(substr(to_char(lv_emp_age_nt(indx).empno),3));
    if lv_age <20
    then
        lv_emp_age_nt(indx).age := lv_age +20;
    elsif lv_age > 70
    then
        lv_emp_age_nt(indx).age := lv_age -30;
    else
        lv_emp_age_nt(indx).age := lv_age;
    end if;
end loop;

forall indx in lv_emp_age_nt.FIRST..lv_emp_age_nt.LAST
    update emp set age = lv_emp_age_nt(indx).age
    where empno = lv_emp_age_nt(indx).empno;

commit;

exception
when others then
    dbms_output.put_line(sqlerrm);
end;



-------------------------------------------------------------------------------------------------------------
--Name of the salesperson having more than one order
select name
  from salesperson
where sales_id in (
                        select salesperson_id
						  from orders
				    group by salesperson_id
					   having count(distinct order_number)>1
                    );
					
					
-------------------------------------------------------------------------------------------------------------
--Salesperson name, Customer Name and order number of each salesperson's largerst order
select s.name,
          o.order_number,
		  c.name,
		  i.max_amount
  from orders o,
		  salesperson s,
		  customer c,
		  (select salesperson_id,
            		 max(amount) max_amount
			 from orders
	   group by salesperson_id) i
where o.salesperson_id = i.salesperson_id
    and o.amount = i.max_amount
    and i.salesperson_id = s.sales_id
    and c.customer_id = o.cust_id;
	
	
-------------------------------------------------------------------------------------------------------------
--Orders of Salesperson having an order amount more than the average order amount for that sales person along with  Customer Name
select s.name,
          o.order_number,
		  c.name,
		  o.amount
  from orders o,
		  salesperson s,
		  customer c,
		  (select salesperson_id,
            		 avg(amount) avg_amount
			 from orders
	   group by salesperson_id) i
where o.salesperson_id = i.salesperson_id
    and o.amount >= i.avg_amount
    and i.salesperson_id = s.sales_id
    and c.customer_id = o.cust_id;
	
	
-------------------------------------------------------------------------------------------------------------
--3rd hightest salary:
Select distinct sal
  from emp e1
where 3 = (
                Select count(distinct sal)
				  from emp e2
				where e2.sal>=e1.sal);
				
-------------------------------------------------------------------------------------------------------------
--3rd hightest salary with employee name.
Select ename,
          sal
  from emp e1
where 3 = (
                Select count(distinct sal)
				  from emp e2
				where e2.sal>=e1.sal);

				
-------------------------------------------------------------------------------------------------------------
--Finding duplicate records: finds a true duplicate entry having every column value the same
  SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno
      from temp_emp
group by empno, ename, job, mgr, hiredate, sal, comm, deptno
   having count(*)>1;


-------------------------------------------------------------------------------------------------------------
--Finding duplicate records: finds the duplicate value based on a single column
--(here assumption is that if ID is duplicated then all other column values are also duplicated;not necessarily so)
select *
  from temp_emp e1
where rowid != (
                       select max(rowid)
					     from temp_emp e2
					   where e1.empno = e2.empno
					);
--or
    select empno
      from temp_emp
group by empno
   having count(*)>1;
   
   
-------------------------------------------------------------------------------------------------------------
--Find the cumulative sum of salary in each department based on employee number
select empno,
          ename,
		  sal,
		  deptno,
		  sum(sal) over (partition by deptno order by empno)
  from emp
 order by empno;


-------------------------------------------------------------------------------------------------------------
--To find the average salary of each employee compared with other employees hired 1 year or later after the employee:
select e.empno,
          e.ename,
		  sal,
		  hiredate,
		  avg(sal) over (order by hiredate range 365 preceding) avg_sal
  from emp e
 order by hiredate;
 

-------------------------------------------------------------------------------------------------------------
--To find the average salary of each employee compared with other employees hired either 6 months before or 6 months after the employee:
select e.empno,
          e.ename,
		  sal,
		  hiredate,
		  avg(sal) over (order by hiredate range between 182 preceding and 182 following) avg_sal
  from emp e
 order by hiredate;
 --or
 select e.empno,
          e.ename,
		  sal,
		  hiredate,
		  avg(sal) over (order by hiredate range between interval '6' month preceding and interval '6' month following) avg_sal
  from emp e
 order by hiredate;

 
 
-------------------------------------------------------------------------------------------------------------
--Find the employee with maximum salary in each department
select e1.deptno,
          e1.ename,
		  e1.sal
  from emp e1,
		  (select empno,
		             dense_rank() over(partition by deptno order by sal desc) d_rank
			 from emp) e2
where e1.empno = e2.empno
    and e2.d_rank=1;
--OR
select deptno,
          ename,
		  sal
  from emp,
          (select max(sal) max_sal
		     from emp
	   group by deptno) e2
where emp.sal=e2.max_sal
order by deptno;


-------------------------------------------------------------------------------------------------------------
--Find the employee with maximum salary and second maximum salary in each department
select e1.deptno,
          e1.ename,
		  e1.sal,
		  e2.d_rank
  from emp e1,
		  (select empno,
		             dense_rank() over(partition by deptno order by sal desc) d_rank
			 from emp) e2
where e1.empno = e2.empno
    and e2.d_rank in (1,2)
order by e1.deptno, e2.d_rank;



-------------------------------------------------------------------------------------------------------------
-- How each employee's salary compare with the average salary of the first year hires of their department
SELECT empno, deptno, TO_CHAR(hiredate,'YYYY') HIRE_YR,
sal,
TRUNC(
    AVG(sal)
    KEEP (DENSE_RANK FIRST ORDER BY TO_CHAR(hiredate,'YYYY') )
    OVER (PARTITION BY deptno)
    ) AVG_SAL_YR1_HIRE
FROM emp
ORDER BY deptno, empno, HIRE_YR;


-------------------------------------------------------------------------------------------------------------
-- For each employee give the count of employees getting half more that their 
-- salary and also the count of employees in the departments 20 and 30 getting half  less than their salary.
SELECT deptno,
            empno,
			sal,
            count(*) OVER (PARTITION BY deptno
			                            ORDER BY sal RANGE
												BETWEEN UNBOUNDED PRECEDING AND (sal/2) PRECEDING) CNT_LT_HALF,
			COUNT(*) OVER (PARTITION BY deptno
			                              ORDER BY sal RANGE
												BETWEEN (sal/2) FOLLOWING AND UNBOUNDED FOLLOWING) CNT_MT_HALF
   FROM emp
 WHERE deptno IN (20, 30)
ORDER BY deptno, sal;


-------------------------------------------------------------------------------------------------------------
--Employees with the highest 5 salaries
select e.*
  from emp e,
          (select empno,
		             rank() over(order by sal desc) d_rank
			 from emp) rt
where e.empno = rt.empno
    and rt.d_rank <=5;
	
	
-------------------------------------------------------------------------------------------------------------
--Employees with the lowest 5 salaries
select e.*
  from emp e,
          (select empno,
		             rank() over(order by sal) d_rank
			 from emp) rt
where e.empno = rt.empno
    and rt.d_rank <=5;
	
	
-------------------------------------------------------------------------------------------------------------
--Find distinct records without using DISTINCT
select *
  from test_emp t
 where rowid = (
                select max(rowid)
                  from test_emp t2
                 where t.empno = t2.empno
            );
			
-------------------------------------------------------------------------------------------------------------
--Find duplicate records
select *
  from test_emp t
 where rowid != (
                select max(rowid)
                  from test_emp t2
                 where t.empno = t2.empno
            );
			
			
-------------------------------------------------------------------------------------------------------------
--Create a heirarchical realtionship betweeen manager and employees
select lpad(' ',2*(level-1)) || ename
  from emp
start with mgr is null
connect by prior empno = mgr;

-------------------------------------------------------------------------------------------------------------
--Display each character in the text 'ORACLE' in different columns
Select Substr('ORACLE',Level,1)
 From Dual
Connect By Level<= Length('ORACLE');


-------------------------------------------------------------------------------------------------------------
--Find all employees who joined in 1981
select *
  from emp
where to_char(hiredate, 'YYYY') = 1981;


-------------------------------------------------------------------------------------------------------------
--Find the manager of each employee:
select e1.empno,
          e1.ename,
		  e2.ename
  from emp e1, emp e2
where e1.mgr = e2.empno;


-------------------------------------------------------------------------------------------------------------
--Find manager of each employee using CONNECT BY
select ename,
          (select e2.ename
		     from emp e2
		   where e2.empno=e.mgr) mgr_name,
		  deptno
  from emp e
where deptno in (10,20)
start with mgr is null
connect by prior empno = mgr
order by deptno;


-------------------------------------------------------------------------------------------------------------
--passing cursor variable using REF CURSOR
DECLARE
    TYPE t_my_cursor IS REF CURSOR;
    lv_my_cursor t_my_cursor;				--also we can use the system cursor type as: lv_my_cursor SYS_REFCURSOR;
    lv_param VARCHAR2(10);
    lv_var1 NUMBER;
    lv_var2 VARCHAR2(100);
    
    PROCEDURE my_inner_proc(
        p_parameter IN VARCHAR2,
        p_my_cursor OUT t_my_cursor		--also we can use the system cursor type as: lv_my_cursor SYS_REFCURSOR;
        )
    IS
    BEGIN
        IF p_parameter = 'emp'
        THEN
            OPEN p_my_cursor FOR
                SELECT empno, ename FROM emp WHERE ROWNUM=1;
        ELSIF p_parameter = 'dept'
        THEN
            OPEN p_my_cursor FOR
                SELECT deptno, dname FROM dept WHERE ROWNUM=1;
        END IF;
    
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR IS: ' || SQLERRM);
    END;

BEGIN

    lv_param := 'emp';
    my_inner_proc(lv_param, lv_my_cursor);
    FETCH lv_my_cursor INTO lv_var1, lv_var2;
    CLOSE lv_my_cursor;
    dbms_output.put_line(lv_var1 || ' :' || lv_var2);

EXCEPTION
    WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR STACK: ' || dbms_utility.format_error_stack);
            DBMS_OUTPUT.PUT_LINE('CALL STACK: ' || dbms_utility.format_call_stack);
            DBMS_OUTPUT.PUT_LINE('ERROR BACKTRACE: ' || dbms_utility.format_error_backtrace);
END;



-------------------------------------------------------------------------------------------------------------
--Usage of REF CURSOR types with dynamic query, bind variables and collections
DECLARE
    TYPE t_my_cursor IS REF CURSOR;
    lv_my_cursor t_my_cursor;
    lv_param VARCHAR2(100);
    lv_param_value NUMBER;
    TYPE t_my_rec IS RECORD(
        lv_empno emp.empno%TYPE,
        lv_ename emp.ename%TYPE
        );
    TYPE t_my_coll IS TABLE OF t_my_rec;
    lv_my_coll t_my_coll;

    PROCEDURE my_inner_proc(
        p_parameter IN VARCHAR2,
        p_param_value IN NUMBER,
        p_my_cursor OUT t_my_cursor
        )
    IS
        lv_query VARCHAR2(1000);
    BEGIN
        lv_query := 'SELECT empno, ename FROM emp ';
        IF p_parameter = 'DEPARTMENT'
        THEN
            lv_query := lv_query || ' WHERE deptno = :1';			--additional bind variables can be given sequential numbers like :2, :3, etc
        ELSIF p_parameter = 'SALARY'
        THEN
            lv_query := lv_query || ' WHERE sal > :1' ;
        END IF;
        OPEN p_my_cursor FOR lv_query USING p_param_value;  --if there  are additional bind variables seperate them with comma here

    
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR IS: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('LINE NUMBER : ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    END;

BEGIN

    lv_param := 'DEPARTMENT';
    lv_param_value := 10;
    my_inner_proc(lv_param, lv_param_value, lv_my_cursor);
    IF lv_my_cursor%ISOPEN
    THEN
        FETCH lv_my_cursor BULK COLLECT INTO lv_my_coll;
        CLOSE lv_my_cursor;
        FOR indx IN lv_my_coll.FIRST..lv_my_coll.LAST
        LOOP
            dbms_output.put_line(lv_my_coll(indx).lv_empno || ' :' ||lv_my_coll(indx).lv_ename);
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('CURSOR IS CLOSED');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR BACKTRACE: ' || dbms_utility.format_error_backtrace);
            DBMS_OUTPUT.PUT_LINE('ERROR STACK: ' || dbms_utility.format_error_stack);
END;

-------------------------------------------------------------------------------------------------------------
--Previoius block but this time using functions:
DECLARE
    TYPE t_my_cursor IS REF CURSOR;			--if using SYS_REFCURSOR no need of declaring a user cusror type
    lv_my_cursor t_my_cursor;						--t_my_cursor can be replaced with SYS_REFCURSOR
    lv_param VARCHAR2(100);
    lv_param_value NUMBER;
    TYPE t_my_rec IS RECORD(
        lv_empno emp.empno%TYPE,
        lv_ename emp.ename%TYPE
        );
    TYPE t_my_coll IS TABLE OF t_my_rec;
    lv_my_coll t_my_coll;

    FUNCTION my_inner_func(
        p_parameter VARCHAR2,
        p_param_value NUMBER
        )
    RETURN t_my_cursor								--t_my_cursor can be replaced with SYS_REFCURSOR
    IS
        lv_my_cursor t_my_cursor;					--t_my_cursor can be replaced with SYS_REFCURSOR
        lv_query VARCHAR2(1000);
    BEGIN
        lv_query := 'SELECT empno, ename FROM emp ';
        IF p_parameter = 'DEPARTMENT'
        THEN
            lv_query := lv_query || ' WHERE deptno = :1';
        ELSIF p_parameter = 'SALARY'
        THEN
            lv_query := lv_query || ' WHERE sal > :1' ;
        END IF;
        OPEN lv_my_cursor FOR lv_query USING p_param_value;
        RETURN lv_my_cursor;
    
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR IS: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('LINE NUMBER : ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    END;

BEGIN

    lv_param := 'DEPARTMENT';
    lv_param_value := 20;
    lv_my_cursor := my_inner_func(lv_param, lv_param_value);
    IF lv_my_cursor%ISOPEN
    THEN
        FETCH lv_my_cursor BULK COLLECT INTO lv_my_coll;
        CLOSE lv_my_cursor;
        FOR indx IN lv_my_coll.FIRST..lv_my_coll.LAST
        LOOP
            dbms_output.put_line(lv_my_coll(indx).lv_empno || ' :' ||lv_my_coll(indx).lv_ename);
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('CURSOR IS CLOSED');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR BACKTRACE: ' || dbms_utility.format_error_backtrace);
            DBMS_OUTPUT.PUT_LINE('ERROR STACK: ' || dbms_utility.format_error_stack);
END;


-------------------------------------------------------------------------------------------------------------
--Previoius block but this time returning a nested table instead of returning a cusror
DECLARE

    lv_param VARCHAR2(100);
    lv_param_value NUMBER;
    TYPE t_my_rec IS RECORD(
        lv_empno emp.empno%TYPE,
        lv_ename emp.ename%TYPE
        );
    TYPE t_my_coll IS TABLE OF t_my_rec;
    lv_my_coll t_my_coll;

    FUNCTION my_inner_func(
        p_parameter VARCHAR2,
        p_param_value NUMBER
        )
    RETURN t_my_coll
    IS
        lv_my_cursor SYS_REFCURSOR;
        lv_my_inner_coll t_my_coll;
        lv_query VARCHAR2(1000);
    BEGIN
        lv_query := 'SELECT empno, ename FROM emp ';
        IF p_parameter = 'DEPARTMENT'
        THEN
            lv_query := lv_query || ' WHERE deptno = :1';
        ELSIF p_parameter = 'SALARY'
        THEN
            lv_query := lv_query || ' WHERE sal > :1' ;
        END IF;
        
        OPEN lv_my_cursor FOR lv_query USING p_param_value;
        FETCH  lv_my_cursor BULK COLLECT INTO lv_my_inner_coll;
        CLOSE lv_my_cursor;
        
        RETURN lv_my_inner_coll;
    
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR IS: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('LINE NUMBER : ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    END;

BEGIN

    lv_param := 'SALARY';
    lv_param_value := 2500;
    
    lv_my_coll := my_inner_func(lv_param, lv_param_value);
    FOR indx IN lv_my_coll.FIRST..lv_my_coll.LAST
    LOOP
        dbms_output.put_line(lv_my_coll(indx).lv_empno || ' :' ||lv_my_coll(indx).lv_ename);
    END LOOP;
    

EXCEPTION
    WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR BACKTRACE: ' || dbms_utility.format_error_backtrace);
            DBMS_OUTPUT.PUT_LINE('ERROR STACK: ' || dbms_utility.format_error_stack);
END;

-------------------------------------------------------------------------------------------------------------
--Differene of usage of cursor variable and bulk collection
DECLARE

    CURSOR my_cursor_cur IS
        SELECT empno, ename FROM EMP WHERE DEPTNO = 20 ORDER BY ename;
    
    my_cursor_rec my_cursor_cur%rowtype;
    
    TYPE t_my_ntt IS TABLE OF my_cursor_cur%rowtype;
    lv_my_cursor_nt t_my_ntt;
    
BEGIN
    
    --using normal cursor variable
    OPEN my_cursor_cur;
    LOOP
        FETCH my_cursor_cur INTO my_cursor_rec;
        EXIT WHEN my_cursor_cur%NOTFOUND;
        dbms_output.put_line(my_cursor_rec.ename);
    END LOOP;
    CLOSE my_cursor_cur;
    
    dbms_output.put_line('--------------------------------');
    
    --using collections
    OPEN my_cursor_cur;
    FETCH my_cursor_cur BULK COLLECT INTO lv_my_cursor_nt;
    FOR indx IN lv_my_cursor_nt.FIRST..lv_my_cursor_nt.LAST
    LOOP
        dbms_output.put_line(lv_my_cursor_nt(indx).ename);
    END LOOP;
    
EXCEPTION
    WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR BACKTRACE: ' || dbms_utility.format_error_backtrace);
            DBMS_OUTPUT.PUT_LINE('ERROR STACK: ' || dbms_utility.format_error_stack);
END;