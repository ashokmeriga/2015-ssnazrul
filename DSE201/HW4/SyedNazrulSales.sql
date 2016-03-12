1. 

SELECT customer_name,sum(quantity),sum(price) FROM sales.sale s NATURAL JOIN sales.customer c GROUP BY c.customer_id;

--Baseline: "GroupAggregate  (cost=277118.03..330611.22 rows=100000 width=21)"

CREATE TABLE sales.S1 AS
SELECT customer_name,sum(quantity) AS QSUM,sum(price) AS PSUM FROM sales.sale s NATURAL JOIN sales.customer c GROUP BY c.customer_id;

SELECT * FROM sales.S1;

--Final: "Seq Scan on s1  (cost=0.00..14.30 rows=430 width=158)"


2. 

SELECT state_name,sum(quantity), sum(price) FROM sales.sale s NATURAL JOIN sales.customer c NATURAL JOIN sales.state st GROUP BY st.state_name;

--Baseline: "HashAggregate  (cost=91931.12..91931.75 rows=50 width=128)"

CREATE TABLE sales.S2 AS
SELECT state_name,sum(quantity) AS QSUM, sum(price) AS PSUM FROM sales.sale s NATURAL JOIN sales.customer c NATURAL JOIN sales.state st GROUP BY st.state_name;

SELECT * FROM sales.S2;

--Final: "Seq Scan on s2  (cost=0.00..14.30 rows=430 width=158)"


3. 

SELECT product_id,sum(quantity),sum(price) AS dollar_value FROM sales.sale s WHERE customer_id =1 GROUP BY product_id ORDER BY dollar_value;

--Baseline: "Sort  (cost=37739.03..37739.04 rows=1 width=14)"

CREATE TABLE sales.S3 AS
SELECT product_id,sum(quantity),sum(price) AS dollar_value FROM sales.sale s WHERE customer_id =1 GROUP BY product_id ORDER BY dollar_value;

SELECT * FROM sales.S3;

--Final: "Seq Scan on s3  (cost=0.00..21.00 rows=1100 width=44)"


4.

SELECT state_name,ca.category_id,sum(price) FROM
sales.sale sa NATURAL JOIN sales.customer cu NATURAL JOIN sales.state st NATURAL JOIN sales.category ca NATURAL JOIN sales.product p;
GROUP BY state_name,ca.category_id;

--Baseline: "GroupAggregate  (cost=485594.31..508719.31 rows=250000 width=128)"

CREATE TABLE sales.S4 AS
SELECT state_name,ca.category_id,sum(price) FROM
sales.sale sa NATURAL JOIN sales.customer cu NATURAL JOIN sales.state st NATURAL JOIN sales.category ca NATURAL JOIN sales.product p;
GROUP BY state_name,ca.category_id;

SELECT * FROM sales.S4;

--Final: "Seq Scan on s4  (cost=0.00..349.92 rows=10692 width=154)"


5.

SELECT cate.category_id,cust.customer_id,sum(quantity),sum(price) FROM 
(SELECT category_id,sum(price) AS dollar_value FROM
sales.category NATURAL JOIN sales.product NATURAL JOIN sales.sale
GROUP BY category_id ORDER BY dollar_value DESC limit 10) AS cate,
(SELECT customer_id,sum(price) AS dollar_value FROM sales.sale
GROUP BY customer_id ORDER BY dollar_value DESC limit 10) AS cust, sales.sale s,sales.product p
WHERE p.category_id = cate.category_id and s.customer_id = cust.customer_id and s.product_id = p.product_id
GROUP BY cate.category_id,cust.customer_id ORDER BY cate.category_id;

--Baseline: "Sort  (cost=206072.90..206073.10 rows=80 width=18)"

CREATE TABLE sales.S5 AS
SELECT cate.category_id,cust.customer_id,sum(quantity) AS QSUM,sum(price) AS PSUM FROM 
(SELECT category_id,sum(price) AS dollar_value FROM
sales.category NATURAL JOIN sales.product NATURAL JOIN sales.sale
GROUP BY category_id ORDER BY dollar_value DESC limit 10) AS cate,
(SELECT customer_id,sum(price) AS dollar_value FROM sales.sale
GROUP BY customer_id ORDER BY dollar_value DESC limit 10) AS cust, sales.sale s,sales.product p
WHERE p.category_id = cate.category_id and s.customer_id = cust.customer_id and s.product_id = p.product_id
GROUP BY cate.category_id,cust.customer_id ORDER BY cate.category_id;

SELECT * FROM sales.S5;

--Final: "Seq Scan on s4  (cost=0.00..593.00 rows=35000 width=21)"
