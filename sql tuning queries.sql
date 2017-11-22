--Index hint
------------
select /*+ index(customer cust_primary_key_idx) */ * from customer;

--If the table has an alias, then alias name must be used instead of table name
select /*+ index(c cust_primary_key_idx) */ * from customer c;

--full hint is not consistent with index hint. So below query is invalid
select /*+ full(c) index(c cust_primary_key_idx) */ * from customer c;