select * from gold.dim_customers

-- Explore All Objects in the Database
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Explore All Columns in the Database
SELECT * FROM INFORMATION_SCHEMA. COLUMNS
where TABLE_NAME = 'dim_customers'

/* Identifying the unique values (or categories) in each dimension.

Recognizing how data might be grouped or segmented,
which is useful for later analysis.*/

-- Explore All Countries our customers come from.
SELECT DISTINCT country FROM gold.dim_customers

-- Explore All Categories "The major Divisions"
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_product
ORDER BY 1,2,3

/*
if you are aggregating by the category you will get only four rows
if you are aggregating by the products you will get hundreds of rows 
*/

-- Date Exploration
/*
Identify the earliest and latest dates (boundaries).
Understand the scope of data and the timespan.
*/

-- Find the date of the first and last order
-- How many years of sales are avaiable
SELECT
MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date,
DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_year,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales

-- Find the youngest and the oldest customer
SELECT
MIN(birthdate) AS oldest_birthdate,
DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldeat_age,
MAX(birthdate) AS youngest_birthdate,
DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers

-- Measures Exploration

-- Calculate the key metric of the business (Big Numbers)
-- Highest Level of Aggregation | Lowest Level of Detail

-- Find the Total Sales
SELECT SUM(sales_amount) AS total_sales FROM gold. fact_sales

-- Find how many items are sold
SELECT SUM(quantity) AS total_quantity FROM gold. fact_sales

-- Find the average selling price
SELECT AVG(price) AS avg_price FROM gold.fact_sales

-- Find the Total number of Orders
SELECT COUNT(order_number) AS total_orders FROM gold. fact_sales
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold. fact_sales

-- Find the total number of products
SELECT COUNT(product_name) AS total_products FROM gold.dim_product
SELECT COUNT(DISTINCT product_name) AS total_products FROM gold.dim_product

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers

-- Find the total number of customers that has placed an order
SELECT COUNT(customer_key) AS total_customers FROM gold. fact_sales
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold. fact_sales 

-- Generate a Report that shows all key metrics of the business

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold. fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold. fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold. fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_number) FROM gold. fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(product_name) FROM gold.dim_product
UNION ALL
SELECT 'Total Nr. Customers', COUNT(customer_key) FROM gold.dim_customers

-- Magnitude Analysis

/*
it's all about comparing the measure values across different categories and dimensions.
It helps us understand the importance of different categories.
*/

-- Find total customers by countries
SELECT
country,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Find total customers by gender
SELECT
gender,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

-- Find total products by category
SELECT
category,
COUNT (product_key) AS total_products
FROM gold.dim_product
GROUP BY category
ORDER BY total_products DESC

-- What is the average costs in each category?
SELECT
category,
AVG(cost) AS avg_costs
FROM gold.dim_product
GROUP BY category
ORDER BY avg_costs DESC

-- what is the total revenue generated for each category?
select 
p.category,
sum(f.sales_amount) total_revenue
from gold.fact_sales f
left join gold.dim_product p
on p.product_key = f.product_key
group by p.category
order by total_revenue desc

-- Our business is making a lot of money selling bikes

-- what is the total revenue geenrated by the each customer?
select 
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by c.customer_key,
c.first_name,
c.last_name
order by total_revenue desc

-- what is the distribution of items sold across countries?
select
c.country,
SUM(f.quantity) as total_sold_items
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by 
c.country
order by total_sold_items desc

-- Ranking Analysis

/*
it is very basic so i'm going to go and order the value of our
Dimension based on a measure in order to identify 
the top performers and as well the bottom performers

Order the values of dimensions by measure.

Top N performers | Bottom N Performers

i'm going to be ranking the dimensions by an aggregated measure. 
*/

-- Which 5 products generate the highest revenue?
SELECT TOP 5
p.product_name,
SUM(f. sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
ON p.product_key = f. product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- Top 5 subcategory
SELECT TOP 5
p. subcategory,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
ON p.product_key = f.product_key
GROUP BY p. subcategory
ORDER BY total_revenue DESC

-- Window founction 
SELECT
* from(
		SELECT
		p.product_name,
		SUM(f.sales_amount) total_revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
		FROM gold.fact_sales f
		LEFT JOIN gold.dim_product p
		ON p.product_key = f.product_key
		group by p.product_name)t 
where rank_products <= 5

-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
p.product_name,
SUM(f. sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
ON p.product_key = f. product_key
GROUP BY p.product_name
ORDER BY total_revenue 

-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC

-- The 3 customers with the fewest orders placed
SELECT TOP 3
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f. customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_orders