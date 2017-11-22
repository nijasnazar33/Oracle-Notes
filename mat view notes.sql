
-- Materialized views


-- Manual Refresh Options:
---------------------
-- DBMS_MVIEW.REFRESH:  Refreshes one or more Oracle materialized views
-- DBMS_MVIEW.REFRESH_ALL_MVIEWS:  Refreshes all Oracle materialized views
-- DBMS_MVIEW.REFRESH_DEPENDENT:  Refreshes all table-based Oracle materialized views


-- Conditions for Fast Refresh:
-- -An Oracle materialized view log must be present for each detail table.
-- -The RowIDs of all the detail tables must appear in the SELECT list of the MVIEW query definition.
-- -If there are outer joins, unique constraints must be placed on the join columns of the inner table.

-- eg: 
EXECUTE DBMS_MVIEW.REFRESH('emp_dept_sum','F');

--F means Fast refresh and C means Complete refresh

--If the refresh method is not given, default is FORCE
--If ON COMMIT/ON DEMAND is not given, default is ON DEMAND.(ie refresh using dbms_mview.refresh)


--WITH PRIMARY KEY Clause
--Default type 
-- The master table must contain an enabled primary key constraint, and the defining query of the materialized view must specify all of the primary key columns directly. That is, in the defining query, the primary key columns cannot be specified as the argument to a function such as UPPER.

-- WITH ROWID Clause
-- Rowid materialized views are useful if the materialized view does not include all primary key columns of the master tables.
 -- Rowid materialized views must be based on a single table and cannot contain any of the following:
																								-- Distinct or aggregate functions
																								-- GROUP BY or CONNECT BY clauses
																								-- Subqueries
																								-- Joins
																								-- Set operations
-- Rowid materialized views are not eligible for fast refresh after a master table reorganization until a complete refresh has been performed.


-- Conditions for the query used in Mat view:
--		You cannot define a materialized view with a subquery in the select list of the defining query. You can, however, include subqueries elsewhere in the defining query, such as in
 --	 the WHERE clause.
 -- 	Materialized views cannot contain columns of datatype LONG.
 


-- Materialized View Logs
------------------------
-- When DML changes are made to master table data, Oracle Database stores rows describing those changes in the materialized view log and then uses the materialized view log to refresh materialized views based on the master table. This process is called incremental or fast refresh. Without a materialized view log, Oracle Database must reexecute the materialized view query to refresh the materialized view. This process is called a complete refresh. Usually, a fast refresh takes less time than a complete refresh.


-- To fast refresh a materialized join view, you must create a materialized view log for each of the tables referenced by the materialized view.

--Fast refresh is not possible with mat views based on View or Temporary table because:
-- You cannot create a materialized view log for a temporary table or for a view.

-- INCLUDING NEW VALUES:
-- Specify INCLUDING to save both new and old values in the log. If this log is for a table on which you have a single-table materialized aggregate view, and if you want the materialized view to be eligible for fast refresh, then you must specify INCLUDING.

-- EXCLUDING NEW VALUES:
-- Specify EXCLUDING to disable the recording of new values in the log. This is the default. You can use this clause to avoid the overhead of recording new values. Do not use this clause if you have a fast-refreshable single-table materialized aggregate view defined on the master table.



-- eg:
--create materialized view
CREATE MATERIALIZED VIEW emp_sum
ENABLE QUERY REWRITE
AS SELECT deptno,job,SUM(sal)
      FROM emp
GROUP BY deptno,job
  PCTFREE 5
  PCTUSED 60
  NOLOGGING PARALLEL 5
  TABLESPACE users
    STORAGE (INITIAL 50K NEXT 50K)
    USING INDEX STORAGE (INITIAL 25K NEXT 25K)
  REFRESH FAST
  START WITH SYSDATE
NEXT SYSDATE + 1/12;
---This mat view will be refreshed every 2 hours with FAST optionl



execute dbms_mview.refresh('emp_sum');


--create mv logs for the fast refresh 
CREATE MATERIALIZED VIEW LOG ON
   emp_sum
WITH ROWID;
CREATE MATERIALIZED VIEW LOG ON
   dept
WITH ROWID;


-- Materialized views are not eligible for fast refresh if the defining query contains an analytic function.
-- f you specify REFRESH FAST, then the CREATE statement will fail unless materialized view logs already exist for the materialized view master tables. 


--Period refred mat view example:
CREATE MATERIALIZED VIEW LOG ON employees
   WITH PRIMARY KEY
   INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW emp_data 
   PCTFREE 5 PCTUSED 60 
   TABLESPACE example 
   STORAGE (INITIAL 50K NEXT 50K)
   REFRESH FAST NEXT sysdate + 7 
   AS SELECT * FROM employees; 
 --Refreshes every week. Since START WITH clause is not present, the first refresh is going to be 7 days from now.
 
 
 --Automatic refresh mat view example:
 CREATE MATERIALIZED VIEW all_customers
   PCTFREE 5 PCTUSED 60 
   TABLESPACE example 
   STORAGE (INITIAL 50K NEXT 50K) 									--establishes the sizes of the first and second extents of the materialized view as 50 kilobytes each
   USING INDEX STORAGE (INITIAL 25K NEXT 25K)				--establishes the sizes of the first and second extents of the index as 25 kilobytes each.
   REFRESH START WITH ROUND(SYSDATE + 1) + 11/24 
   NEXT NEXT_DAY(TRUNC(SYSDATE), 'MONDAY') + 15/24 
   AS SELECT * FROM sh.customers@remote 
         UNION
      SELECT * FROM sh.customers@local; 
--This view will be  refreshed first on Tomorrow at 11 a.m. Periodic refreshes will be on every Monday at 3 p.m.
 
 
 
 --Create matview logs and matview for Fast refresh
 CREATE MATERIALIZED VIEW LOG ON sales 
   WITH ROWID, SEQUENCE(amount_sold, time_id, prod_id)
   INCLUDNG NEW VALUES; 
   
 CREATE MATERIALIZED VIEW LOG ON times
   WITH ROWID, SEQUENCE (time_id, calendar_year)
   INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW LOG ON products
   WITH ROWID, SEQUENCE (prod_id)
   INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW sales_mv
   BUILD IMMEDIATE
   REFRESH FAST ON COMMIT
   AS SELECT t.calendar_year, p.prod_id, 
      SUM(s.amount_sold) AS sum_sales
      FROM times t, products p, sales s
      WHERE t.time_id = s.time_id AND p.prod_id = s.prod_id
      GROUP BY t.calendar_year, p.prod_id;
--All the columns that are used in the aggregate functions are included i the SEQUENCE clause of mat view logs



----------------------------------------------------------------------------------------------------------
-- The following example creates a materialized view log on the oe.product_information table that specifies INCLUDING NEW VALUES:

CREATE MATERIALIZED VIEW LOG ON product_information 
   WITH ROWID, SEQUENCE (list_price, min_price, category_id), PRIMARY KEY
   INCLUDING NEW VALUES;

-- You could create the following materialized aggregate view to use the product_information log:

CREATE MATERIALIZED VIEW products_mv 
   REFRESH FAST ON COMMIT
   AS SELECT SUM(list_price - min_price), category_id
         FROM product_information 
         GROUP BY category_id;

-- This materialized view is eligible for fast refresh because the log defined on its master table includes both old and new values.
----------------------------------------------------------------------------------------------------------