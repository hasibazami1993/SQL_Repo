-- Monday Coffee -- Data Analysis

SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;


--Coffee Consumers Count
--How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT
	city_name,
	ROUND((population * 0.25)/1000000,2),
	city_rank
FROM city
ORDER BY 2 DESC

--Total Revenue from Coffee Sales
--What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT
	ci.city_name,
	SUM(s.total) as total_revenue
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	WHERE EXTRACT(YEAR FROM sale_date) = 2023
	AND
	EXTRACT(QUARTER FROM sale_date) = 4
GROUP BY 1
ORDER BY 2 DESC

--Sales Count for Each Product
--How many units of each coffee product have been sold?

SELECT
	p.product_name,
	COUNT(s.sale_id) as total_orders
	FROM sales s
	RIGHT JOIN products as p
	ON s.product_id = p.product_id
	GROUP BY 1
	ORDER BY 2 DESC;


--City Population and Coffee Consumers
--Provide a list of cities along with their populations and estimated coffee consumers.	

WITH city_table AS(
SELECT
	city_name,
	ROUND(population * 0.25/1000000,2) as coffee_consumers
FROM city
),

AS
customers_table
SELECT
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cx
FROM sales as s
JOIN customers as c
ON c.customer_id = s.customer_id
JOIN city as ci
ON ci.city_id = c.city_id

--Top Selling Products by City
--What are the top 3 selling products in each city based on sales volume?
SELECT
* FROM
(SELECT
	ci.city_name,
	p.product_name,
	COUNT(s.sale_id) AS total_orders,
	DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
FROM sales s
JOIN products as p
ON s.product_id = p.product_id
JOIN customers as c
ON c.customer_id = s.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1,2) as t1
WHERE rank <= 3
--ORDER BY 2

--Customer Segmentation by City
--How many unique customers are there in each city who have purchased coffee products?

SELECT 
ci.city_name,
COUNT(DISTINCT c.customer_name)
FROM customers c
JOIN city ci
ON c.city_id = ci.city_id
GROUP BY 1
ORDER BY 2 DESC;

--Average Sale vs Rent
--Find each city and their average sale per customer and avg rent per customer

WITH city_table AS (
	SELECT
		ci.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT s.customer_id) AS total_cx,
		ROUND(SUM(s.total)::numeric/COUNT(DISTINCT s.customer_id)::numeric,2) as avg_sale_pr_cx
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent 
AS
(SELECT
	city_name,
	estimated_rent
FROM city
)

SELECT
	cr.city_name,
	cr.estimated_rent,
	ct.total_cx,
	ct.avg_sale_pr_cx,
	ROUND(cr.estimated_rent::numeric / ct.total_cx::numeric,2)
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 5 DESC

--Monthly Sales Growth
--Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
WITH monthly_sales AS(
SELECT 
	ci.city_name,
	EXTRACT(MONTH FROM s.sale_date) as month,
	EXTRACT(YEAR FROM s.sale_date) AS year,
	SUM(s.total) AS total_sales
FROM sales as s
JOIN customers c 
ON c.customer_id = s.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1,2,3
ORDER BY 1,2,3 
),

growth_ratio AS (
SELECT
	city_name,
	month,
	year,
	total_sales as cr_month_sale,
	LAG(total_sales, 1) OVER(PARTITION BY city_name ORDER BY year,month) as last_month_sale
FROM monthly_sales
)

SELECT
	city_name,
	month,
	year,
	cr_month_sale,
	last_month_sale,
	COALESCE(ROUND((cr_month_sale-last_month_sale)::numeric / last_month_sale::numeric,2) * 100,0)
FROM growth_ratio

