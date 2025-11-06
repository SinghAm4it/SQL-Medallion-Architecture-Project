SELECT * FROM gold.dim_customers;
SELECT * FROM gold.dim_products;
SELECT * FROM gold.fact_sales;

-- Dimensions And Measures are 2 type of columns 

-- 1. DIMENSIONS
-- Dimensions are strings, dates and numerical values that can't be aggregated

-- Checking Dimensions Using DISTINCT
-- 1) To know geographical background of customers
SELECT DISTINCT country FROM gold.dim_customers;

-- 2) To know product categories and subcategories
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products
ORDER BY 1,2,3;

-- Date Exploration
-- 1) To check 1st product and the latest product 
SELECT MIN(product_start_dt), MAX(product_start_dt) FROM gold.dim_products;

-- 2) To check the first order , latest order and range between them
SELECT 
	MIN(order_date), 
	MAX(order_date), 
	TIMESTAMPDIFF(YEAR,MIN(order_date),MAX(order_date)) 
FROM gold.fact_sales;

-- 3) To check youngest and oldest customers
SELECT 
	TIMESTAMPDIFF(YEAR,MAX(birth_date),NOW()) AS youngest,
    TIMESTAMPDIFF(YEAR,MIN(birth_date),NOW()) AS oldest
FROM gold.dim_customers;

-- 2. MEASURES
-- Measures are numerical values the can be aggregated

-- Checking aggregated values 
-- 1) AVG and SUM of Sales
SELECT
	AVG(sales_amount),
    SUM(sales_amount)
FROM gold.fact_sales;
    
-- 2) To check total item sold and avg price
SELECT 
	AVG(price),
    SUM(quantity)
FROM gold.fact_sales;

-- 3) To check Total Orders
SELECT COUNT(order_number) FROM gold.fact_sales;
SELECT COUNT(DISTINCT order_number) FROM gold.fact_sales;-- one order can have multiple items

-- 4) Check total no. of products and customers and also those who placed orders
SELECT COUNT(product_name) FROM gold.dim_products;
SELECT COUNT(DISTINCT product_name) FROM gold.dim_products;
SELECT COUNT(customer_number) FROM gold.dim_customers;
SELECT COUNT(DISTINCT customer_number) FROM gold.fact_sales;

-- 3. MAGNITUDE ANALYSIS
-- Measures partitioned by dimensions
SELECT
	country,
    COUNT(customer_number) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY COUNT(customer_number) DESC;

SELECT
	marital_status,
    COUNT(customer_number) AS total_customers
FROM gold.dim_customers
GROUP BY marital_status
ORDER BY COUNT(customer_number) DESC;

SELECT
	gender,
    COUNT(customer_number) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY COUNT(customer_number) DESC;

SELECT
	category,
    COUNT(product_number) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY COUNT(product_number) DESC;

SELECT
	category,
    AVG(product_cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY AVG(product_cost) DESC;

SELECT
	category,
    COUNT(fs.product_number) AS products_ordered
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON fs.product_number = dp.product_number
GROUP BY category
ORDER BY COUNT(product_number) DESC;

SELECT
	country,
    AVG(sales_amount) AS avg_salesbycountry
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dp
ON fs.customer_number = dp.customer_number
GROUP BY country
ORDER BY AVG(sales_amount) DESC;

SELECT
	country,
    SUM(sales_amount) AS total_salesbycountry
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dp
ON fs.customer_number = dp.customer_number
GROUP BY country
ORDER BY SUM(sales_amount) DESC;

SELECT
	fs.customer_number,
    dp.first_name,
    dp.last_name,
    SUM(fs.sales_amount) AS total_salesbycustomers
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dp
ON fs.customer_number = dp.customer_number
GROUP BY fs.customer_number,dp.first_name,dp.last_name
ORDER BY SUM(sales_amount) DESC;

SELECT
	country,
    category,
    SUM(sales_amount) AS total_salesbycountry
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
ON fs.customer_number = dc.customer_number
LEFT JOIN gold.dim_products AS dp
ON fs.product_number = dp.product_number
GROUP BY country,category
ORDER BY country,SUM(sales_amount) DESC;

SELECT
	product_name,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON fs.product_number = dp.product_number
GROUP BY product_name
ORDER BY SUM(sales_amount) DESC
LIMIT 5;

SELECT
	product_name,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON fs.product_number = dp.product_number
GROUP BY product_name
ORDER BY SUM(sales_amount)
LIMIT 5;