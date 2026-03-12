-- ================================================
-- PROJECT: Online Platform Sales in Australia Analytics
-- Author: Sanskar Shrivas
-- Date: 06-03-2026
-- Database: PostgreSQL 18
-- Description: Analysis of 1039 orders across
--              Australian states, customers and
--              account managers
-- ================================================

-- SECTION 1: DATABASE SETUP
-- ________________________________________________

-- Making sure that the Orders table doesn't pre-exist
DROP TABLE IF EXISTS Orders CASCADE;

-- Create the table to copy Orders data into
CREATE TABLE Orders(
	Order_id TEXT,
	Order_date DATE,
	Customer_name Varchar(30),
	Address Varchar(100),
	City Varchar(15),
	stat3 Varchar(5),
	customer_type Varchar(20),
	Acc_manager Varchar(25),
	priority varchar(13),
	prod_name varchar(100),
	prod_cat varchar(25),
	prod_container varchar(20),
	ship_mode varchar(20),
	ship_date date,
	c_price float,
	r_price float,
	quant float,
	sub_total float,
	discount float,
	n_discount float,
	o_total float,
	s_cost float,
	total float
);

-- Clearing table of all previous records
TRUNCATE Orders;

-- Importing csv data into the database
COPY orders(order_id, order_date, Customer_name, address, city, stat3,
customer_type, acc_manager, priority, prod_name, prod_cat,
prod_container, ship_mode, ship_date, c_price, r_price,
quant, sub_total, discount, n_discount, o_total, s_cost, total)
FROM 'D:\ds_learn\SQL\GP1\data\Orders_ship_data.csv'
DELIMITER ','
CSV HEADER;

-- Ensuring data is correctly imported
SELECT * FROM Orders;

SELECT MIN(Order_date),MAX(Order_date) from Orders;

-- ________________________________________________

-- Making sure that the Sales16 table doesn't pre-exist
DROP TABLE IF EXISTS Sales16 CASCADE;

-- Create the table to copy Sales 2016 data into
CREATE TABLE Sales16(
	acc_manager varchar(25),
	qtr1 float,
	qtr2 float,
	qtr3 float,
	qtr4 float
);

-- Clearing table of all previous records
TRUNCATE Sales16;

-- Importing csv data into the database
COPY Sales16(acc_manager,qtr1,qtr2,qtr3,qtr4)
FROM 'D:\ds_learn\SQL\GP1\data\Sales 2016.csv'
DELIMITER ','
CSV HEADER;

-- Ensuring data is correctly imported
SELECT * FROM Sales16;

-- Removing aggregated 'Total' row that was mistakenly included in source data
DELETE FROM sales16 WHERE acc_manager='Total';


-- SECTION 2: DATA QUALITY CHECKS
-- ________________________________________________

-- Checking for duplicate order IDs
SELECT order_id, count(order_id) as order_count 
FROM Orders 
GROUP BY order_id 
HAVING count(order_id) > 1;

-- Investigating the duplicate rows (found: 6159-2 and 5768-2)
-- Conclusion: different products and timestamps, not true duplicates
SELECT * FROM Orders WHERE order_id IN ('6159-2','5768-2');

-- Checking for NULL values in key columns
-- Result: 1039 rows returned = no nulls found
SELECT count(*) as no_of_null_orders 
FROM Orders 
WHERE NOT(order_id IS NULL OR address IS NULL OR city IS NULL OR customer_type IS NULL);


-- SECTION 3: CUSTOMER ANALYSIS
-- ________________________________________________

-- Top customer by total spend
-- Result: Clytie Kelty
SELECT customer_name, ROUND(sum(total)::numeric,2) as total 
FROM Orders 
GROUP BY customer_name 
ORDER BY sum(total) DESC 
LIMIT 1;

-- Top customer by number of orders
-- Result: Patrick Jones
SELECT customer_name, COUNT(order_id) as no_of_orders 
FROM Orders 
GROUP BY customer_name 
ORDER BY no_of_orders DESC 
LIMIT 1;

-- Top customer by total items purchased
-- Result: Mike Kennedy (202 units)
SELECT customer_name, SUM(quant) as no_of_items 
FROM Orders 
GROUP BY customer_name 
ORDER BY SUM(quant) DESC 
LIMIT 1;


-- SECTION 4: GEOGRAPHIC ANALYSIS
-- ________________________________________________

-- State generating the most revenue
-- Result: NSW
SELECT stat3, ROUND(SUM(total)::numeric,2) as total 
FROM Orders 
GROUP BY stat3 
ORDER BY SUM(total) DESC 
LIMIT 1;

-- Top product category by revenue in NSW
-- Result: Technology
SELECT prod_cat, ROUND(SUM(total)::numeric,2) as total 
FROM Orders 
WHERE stat3 = 'NSW' 
GROUP BY prod_cat 
ORDER BY SUM(total) DESC 
LIMIT 1;


-- SECTION 5: MANAGER PERFORMANCE
-- ________________________________________________

-- Top account manager by total revenue
-- Result: Yvette Biti
SELECT acc_manager, COUNT(order_id) as orders, SUM(quant) as items_count, ROUND(SUM(total)::numeric,2) as total 
FROM Orders 
GROUP BY acc_manager 
ORDER BY SUM(total) DESC 
LIMIT 1;

-- Composite performance score (customers x avg spend)
-- Yvette Biti leads due to consistent performance across both metrics
SELECT acc_manager,
	COUNT(customer_name) as no_of_customers,
	ROUND(avg(total)::numeric,2) as avg_spend,
	ROUND(COUNT(customer_name)*avg(total)::numeric,2) as composite_score 
FROM Orders 
GROUP BY acc_manager 
ORDER BY composite_score DESC;

-- Manager performance vs quarterly targets (2016 only)
SELECT o.acc_manager, s.qtr1, s.qtr2, s.qtr3, s.qtr4,
	ROUND(sum(o.total)::numeric,2) as t_16 
FROM sales16 as s 
JOIN Orders as o ON o.acc_manager = s.acc_manager 
WHERE o.order_date BETWEEN '2016-01-01' AND '2016-12-31' 
GROUP BY o.acc_manager, s.qtr1, s.qtr2, s.qtr3, s.qtr4 
ORDER BY t_16 DESC;

-- Categorizing managers by 2016 performance
-- Good: >= 30000 | Average: 15000-30000 | Need Improvement: < 15000
SELECT o.acc_manager, s.qtr1, s.qtr2, s.qtr3, s.qtr4,
	ROUND(sum(o.total)::numeric,2) as t_16,
	CASE
		WHEN ROUND(sum(o.total)::numeric,2) >= 30000 THEN 'Good'
		WHEN ROUND(sum(o.total)::numeric,2) >= 15000 THEN 'Average'
		ELSE 'Need Improvement'
	END as performance
FROM sales16 as s 
JOIN Orders as o ON o.acc_manager = s.acc_manager 
WHERE o.order_date BETWEEN '2016-01-01' AND '2016-12-31' 
GROUP BY o.acc_manager, s.qtr1, s.qtr2, s.qtr3, s.qtr4 
ORDER BY t_16 DESC;

-- Managers whose 2016 quarterly total exceeds the group average (~36277)
-- Result: Aanya Zhang (42424)
SELECT acc_manager, ROUND((qtr1+qtr2+qtr3+qtr4)::numeric,2) as yearly_total 
FROM sales16
WHERE (qtr1+qtr2+qtr3+qtr4) > (SELECT AVG(qtr1+qtr2+qtr3+qtr4) FROM Sales16);


-- SECTION 6: VIEWS
-- ________________________________________________

-- View: Customer performance summary
CREATE OR REPLACE VIEW v_customer_performance AS
SELECT 
	customer_name,
	ROUND(SUM(total)::numeric,2) as total_spend,
	COUNT(order_id) as total_orders,
	SUM(quant) as total_items,
	ROUND(AVG(total)::numeric,2) as avg_order_value
FROM Orders
GROUP BY customer_name
ORDER BY total_spend DESC;

-- View: Manager performance categorization for 2016
CREATE OR REPLACE VIEW v_manager_performance_2016 AS
SELECT o.acc_manager, s.qtr1, s.qtr2, s.qtr3, s.qtr4,
	ROUND(SUM(o.total)::numeric,2) as t_16,
	CASE
		WHEN ROUND(SUM(o.total)::numeric,2) >= 30000 THEN 'Good'
		WHEN ROUND(SUM(o.total)::numeric,2) >= 15000 THEN 'Average'
		ELSE 'Need Improvement'
	END as performance
FROM sales16 as s
JOIN Orders as o ON o.acc_manager = s.acc_manager
WHERE o.order_date BETWEEN '2016-01-01' AND '2016-12-31'
GROUP BY o.acc_manager, s.qtr1, s.qtr2, s.qtr3, s.qtr4
ORDER BY t_16 DESC;

-- View: Managers above average 2016 performance
CREATE OR REPLACE VIEW v_above_avg_managers AS
SELECT acc_manager, ROUND((qtr1+qtr2+qtr3+qtr4)::numeric,2) as yearly_total
FROM sales16
WHERE (qtr1+qtr2+qtr3+qtr4) > (SELECT AVG(qtr1+qtr2+qtr3+qtr4) FROM Sales16)
ORDER BY yearly_total DESC;

-- Querying views
SELECT * FROM v_customer_performance;
SELECT * FROM v_manager_performance_2016;
SELECT * FROM v_above_avg_managers;

-- ================================================
-- END OF PROJECT
-- ================================================