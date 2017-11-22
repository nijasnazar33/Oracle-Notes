-- Create DEPT table which will be the parent table of the EMP table. 
create table dept(  
  deptno     number(2,0),  
  dname      varchar2(14),  
  loc        varchar2(13),  
  constraint pk_dept primary key (deptno)  
);

-- Create the EMP table which has a foreign key reference to the DEPT table.  The foreign key will require that the DEPTNO in the EMP table exist in the DEPTNO column in the DEPT table.
create table emp(  
  empno    number(4,0),  
  ename    varchar2(10),  
  job      varchar2(9),  
  mgr      number(4,0),  
  hiredate date,  
  sal      number(7,2),  
  comm     number(7,2),  
  deptno   number(2,0),  
  constraint pk_emp primary key (empno),  
  constraint fk_deptno foreign key (deptno) references dept (deptno)  
);

-- Insert row into DEPT table using named columns.
insert into DEPT (DEPTNO, DNAME, LOC)
values(10, 'ACCOUNTING', 'NEW YORK');

-- Insert a row into DEPT table by column position.
insert into dept  
values(20, 'RESEARCH', 'DALLAS');

insert into dept  
values(30, 'SALES', 'CHICAGO');

insert into dept  
values(40, 'OPERATIONS', 'BOSTON');

-- Insert EMP row, using TO_DATE function to cast string literal into an oracle DATE format.
insert into emp  
values(  
 7839, 'KING', 'PRESIDENT', null,  
 to_date('17-11-1981','dd-mm-yyyy'),  
 5000, null, 10  
);

insert into emp  
values(  
 7698, 'BLAKE', 'MANAGER', 7839,  
 to_date('1-5-1981','dd-mm-yyyy'),  
 2850, null, 30  
);

insert into emp  
values(  
 7782, 'CLARK', 'MANAGER', 7839,  
 to_date('9-6-1981','dd-mm-yyyy'),  
 2450, null, 10  
);

insert into emp  
values(  
 7566, 'JONES', 'MANAGER', 7839,  
 to_date('2-4-1981','dd-mm-yyyy'),  
 2975, null, 20  
);

insert into emp  
values(  
 7788, 'SCOTT', 'ANALYST', 7566,  
 to_date('13-JUL-87','dd-mm-rr') - 85,  
 3000, null, 20  
);

insert into emp  
values(  
 7902, 'FORD', 'ANALYST', 7566,  
 to_date('3-12-1981','dd-mm-yyyy'),  
 3000, null, 20  
);

insert into emp  
values(  
 7369, 'SMITH', 'CLERK', 7902,  
 to_date('17-12-1980','dd-mm-yyyy'),  
 800, null, 20  
);

insert into emp  
values(  
 7499, 'ALLEN', 'SALESMAN', 7698,  
 to_date('20-2-1981','dd-mm-yyyy'),  
 1600, 300, 30  
);

insert into emp  
values(  
 7521, 'WARD', 'SALESMAN', 7698,  
 to_date('22-2-1981','dd-mm-yyyy'),  
 1250, 500, 30  
);

insert into emp  
values(  
 7654, 'MARTIN', 'SALESMAN', 7698,  
 to_date('28-9-1981','dd-mm-yyyy'),  
 1250, 1400, 30  
);

insert into emp  
values(  
 7844, 'TURNER', 'SALESMAN', 7698,  
 to_date('8-9-1981','dd-mm-yyyy'),  
 1500, 0, 30  
);

insert into emp  
values(  
 7876, 'ADAMS', 'CLERK', 7788,  
 to_date('13-JUL-87', 'dd-mm-rr') - 51,  
 1100, null, 20  
);

insert into emp  
values(  
 7900, 'JAMES', 'CLERK', 7698,  
 to_date('3-12-1981','dd-mm-yyyy'),  
 950, null, 30  
);

insert into emp  
values(  
 7934, 'MILLER', 'CLERK', 7782,  
 to_date('23-1-1982','dd-mm-yyyy'),  
 1300, null, 10  
);


alter table emp add age number;

create table salesperson(
sales_id number,
name varchar2(100),
age number,
salary number,
constraint sp_id_pk primary key (sales_id)
);

insert into salesperson values(1,'Abe',61,140000);
insert into salesperson values(2,'Bob',34,44000);
insert into salesperson values(5,'Chris',34,40000);
insert into salesperson values(7,'Dan',41,52000);
insert into salesperson values(8,'Ken',57,115000);
insert into salesperson values(11,'Joe',38,38000);

create table orders(
order_number number primary key,
order_date date,
cust_id number,
salesperson_id number,
amount number
);

insert into orders values(10, to_date('08/02/96','MM/DD/YY'), 4, 2, 2400);
insert into orders values(20, to_date('01/30/99','MM/DD/YY'), 4, 8, 1800);
insert into orders values(30, to_date('07/14/95','MM/DD/YY'), 9, 1, 460);
insert into orders values(40, to_date('01/29/98','MM/DD/YY'), 7, 2, 540);
insert into orders values(50, to_date('02/03/98','MM/DD/YY'), 6, 7, 600);
insert into orders values(60, to_date('03/02/98','MM/DD/YY'), 6, 7, 720);
insert into orders values(70, to_date('05/06/98','MM/DD/YY'), 9, 7, 150);


create table customer(
customer_id number primary key,
name varchar2(100),
city varchar2(100),
industry_type varchar2(1)
);

insert into customer values(4, 'Samsonic','pleasant', 'J');
insert into customer values(6, 'Panasung','oaktown', 'J');
insert into customer values(7, 'Samony','jackson', 'B');
insert into customer values(9, 'Orange','jackson', 'B');

alter table orders
add constraint cust_id_fk FOREIGN KEY (cust_id) REFERENCES customer(customer_id);