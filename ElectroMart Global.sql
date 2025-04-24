--PROBLEM STATEMENT:
--ElectroMart Global, a global electronics retailer, 
--is facing challenges in sales performance, inventory management, 
--supplier efficiency, and customer purchasing behavior. 
--The leadership team has hired you, a Data Analyst, 
--to uncover actionable insights that will help optimize sales, 
--supply chain efficiency and customer retention strategies.

--Your task is to analyze real sales transactions and provide data-driven recommendations.

---LET'S CREATE AND IMPORT TABLES--

CREATE TABLE dim_customers (customer_id varchar,
							 Customer_name varchar,
							 City varchar,
							 Country varchar

);

--CALL OUT DIM CUSTOMERS TABLE--
SELECT *
FROM dim_customers

---let's import the dim date table

CREATE TABLE Dim_dates (date_id int,
						date date
);

--CALL OUT DIM DATES TABLE-
SELECT *
FROM Dim_dates


--Let's import the dim products table
CREATE TABLE Dim_products (product_id varchar,
						   product_name varchar,
						   Category varchar,
						   Supplier_id varchar,
						   Price int
);

--CALL OUT DIM PRODUCTS TABLE--
SELECT *
FROM Dim_products

--let's import dim suppliers table
CREATE TABLE Dim_suppliers (Supplier_id varchar,
							Supplier_name varchar,
							Country varchar,
							Reliability_score int,
							Lead_time_days int
);

--CALL OUT DIM SUPPLIERS TABLE--
SELECT *
FROM Dim_suppliers


---Let's import facts sales table
CREATE TABLE fact_sales (order_id varchar,
						 Customer_id varchar,
						 order_date date,
						 product_id varchar,
						 Quantity int,
						 Unit_price int,
						 discount text,
						 total_amount decimal,
						 status varchar,
						 payment_method varchar

);

--LET'S CALL OUT FACT SALES TABLE
SELECT *
FROM Fact_sales


---NOW LETS GET STARTED WITH THE QUESTIONS--

--1.	Find the Top 5 Revenue-Generating Products Over the Last 6 Months
--RESULT--

SELECT p.product_name, SUM(fs.total_amount) AS total_revenue
FROM Fact_sales AS fs
JOIN
dim_products AS p
ON
fs.product_id = p.product_id
WHERE
order_date >= '2023-03-01' AND order_date <= '2023-08-31'
AND
fs.status = 'Delivered'
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;




--2.	Identify the Most Loyal Customers Who Have Placed 10 or  More Orders
--RESULT--

SELECT c.customer_id, c.customer_name, COUNT(fs.order_id) AS Total_orders
FROM fact_sales AS fs
JOIN
dim_customers AS c
ON
c.customer_id = fs.customer_id
WHERE
status = 'Delivered'
GROUP BY c.customer_id,c.customer_name
HAVING COUNT(fs.order_id)>=10
ORDER BY total_orders DESC;



--3.	Find the Month With the Highest Sales Volume & Revenue
--RESULT--
SELECT d.date_id,  TO_CHAR(order_date, 'YYYY-MM') AS sales_month,
       COUNT(fs.order_id) AS total_orders,
       SUM(fs.total_amount) AS total_revenue
FROM fact_sales AS fs
JOIN 
dim_dates AS d
ON 
fs.order_date = d.date
WHERE fs.status = 'Delivered'
GROUP BY sales_month,date_id
ORDER BY total_revenue DESC
LIMIT 1;




--4.	Identify Suppliers With High Lead Times & Low Reliability Scores
--RESULT--

SELECT s.supplier_name, s.lead_time_days, s.reliability_score
FROM dim_suppliers AS s
WHERE s.reliability_score >85
ORDER BY lead_time_days DESC








---5.	Find the Most Popular Payment Method for High-Value Orders (> $1,000)
--RESULT--

SELECT payment_method, COUNT(order_id) AS Order_count
FROM fact_sales
WHERE total_amount >1000
AND
status = 'Delivered'
GROUP BY payment_method
ORDER BY order_count DESC
LIMIT 5;




--6.	Detect Customers Who Have Placed Orders but Later Canceled the Same Product
--RESULT--
SELECT DISTINCT
n.customer_name,
p.product_name,
o.customer_id,
o.product_id,
o.status
FROM fact_sales As O
JOIN 
dim_customers AS n
ON
o.customer_id = n.customer_id
JOIN
dim_products AS p
ON
o.product_id = p.product_id
WHERE
o.status = 'Canceled'






--7.	Rank the Top 3 Most Efficient Suppliers Based on Lead Time & Reliability
--RESULT--
SELECT supplier_name, lead_time_days, reliability_score
FROM dim_suppliers
ORDER BY reliability_score DESC, lead_time_days ASC
LIMIT 3;








--8.	Identify Product Categories With the Highest Average Order Value
--RESULT--
SELECT p.category, AVG(fs.total_amount) AS avg_order_value
FROM fact_sales AS fs
JOIN dim_products AS p 
ON fs.product_id = p.product_id
WHERE fs.status = 'Delivered'
GROUP BY p.category
ORDER BY avg_order_value DESC;






--9.	Find Customers Who Have Spent the Most in a Single Transaction
--RESULT--

SELECT fs.customer_id, c.customer_name, MAX(total_amount) AS highest_order_value
FROM fact_sales AS fs
JOIN dim_customers AS c
ON fs.customer_id=c.customer_id
WHERE status = 'Delivered'
GROUP BY c.customer_name, fs.customer_id
ORDER BY highest_order_value DESC
LIMIT 5;






