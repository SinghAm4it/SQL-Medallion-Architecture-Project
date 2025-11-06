/*1) Change Over Time 
	Analyzes how a measure evolves over time
    Help to identify trends */

-- Analyzing sales performance over time
SELECT 
	YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_number) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

SELECT 
	DATE_FORMAT(order_date, '%Y-%m') AS order_time,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_number) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m') 
ORDER BY DATE_FORMAT(order_date, '%Y-%m');


/*2) Cumulative Analysis
	Aggregate the data progressively over time
    Helps us understand when are business is growing and declining*/
    
-- Running Total of Sales
SELECT 
	order_time,
    total_sales,
	SUM(total_sales)OVER(ORDER BY order_time) as running_total
FROM(
	SELECT 
		DATE_FORMAT(order_date, '%Y-%m') AS order_time,
		SUM(sales_amount) AS total_sales,
		COUNT(DISTINCT customer_number) AS total_customers,
		SUM(quantity) AS total_quantity
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATE_FORMAT(order_date, '%Y-%m') 
	ORDER BY DATE_FORMAT(order_date, '%Y-%m')
)t ;

-- Moving Average 
SELECT 
	avg_price,
    ROUND(AVG(avg_price)OVER(ORDER BY order_time),0) AS moving_averge
FROM(
    SELECT 
		DATE_FORMAT(order_date, '%Y') AS order_time,
		SUM(sales_amount) AS total_sales,
		COUNT(DISTINCT customer_number) AS total_customers,
		SUM(quantity) AS total_quantity,
        ROUND(AVG(price),0) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATE_FORMAT(order_date, '%Y') 
	ORDER BY DATE_FORMAT(order_date, '%Y')
)v ;


/*3) Performance Analysis
	Compare the current value to target value 
    Or to compare the value to anything else related to it*/
 
WITH yearly_product_sales AS ( 
	SELECT
		YEAR(fs.order_date) AS order_year,
		SUM(fs.sales_amount) AS current_sales,
		dp.product_name
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_products AS dp
	ON fs.product_number = dp.product_number
	WHERE fs.order_date IS NOT NULL
	GROUP BY YEAR(fs.order_date), dp.product_name
)
SELECT 
	order_year,
    product_name,
    current_sales,
    AVG(current_sales)OVER(PARTITION BY product_name) AS avg_sales,
    current_sales-AVG(current_sales)OVER(PARTITION BY product_name) AS diff_sales,
    CASE
		WHEN current_sales-AVG(current_sales)OVER(PARTITION BY product_name)<0 THEN 'Below Average'
        WHEN current_sales-AVG(current_sales)OVER(PARTITION BY product_name)>0 THEN 'Above Average'
        ELSE 'Average'
	END AS avg_change
FROM yearly_product_sales;

WITH yearly_product_sales AS ( 
	SELECT
		YEAR(fs.order_date) AS order_year,
		SUM(fs.sales_amount) AS current_sales,
		dp.product_name
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_products AS dp
	ON fs.product_number = dp.product_number
	WHERE fs.order_date IS NOT NULL
	GROUP BY YEAR(fs.order_date), dp.product_name
)
SELECT 
	order_year,
    product_name,
    current_sales,
    LAG(current_sales,1)OVER(PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
    current_sales - LAG(current_sales,1)OVER(PARTITION BY product_name ORDER BY order_year) AS diff_sales_year,
	CASE
		WHEN current_sales - LAG(current_sales,1)OVER(PARTITION BY product_name ORDER BY order_year)>0 THEN 'Increased'
        WHEN current_sales - LAG(current_sales,1)OVER(PARTITION BY product_name ORDER BY order_year)<0 THEN 'Decreased'
        ELSE 'No change'
	END AS year_change
FROM yearly_product_sales;


/*4) Part to Whole
	Analyzes how an individual part is performing compared to the overall*/
    
SELECT 
	country,
    total_sales,
    overall_sales,
    CONCAT(ROUND((total_sales/overall_sales) * 100,2),'%') AS contribution
FROM(
	SELECT 
		dc.country AS country,
		SUM(fs.sales_amount) AS total_sales,
		SUM(SUM(fs.sales_amount))OVER() AS overall_sales
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_customers AS dc
	ON fs.customer_number = dc.customer_number
	GROUP BY dc.country
)t
ORDER BY ROUND((total_sales/overall_sales) * 100,2) DESC;

SELECT 
	category,
    total_sales,
    overall_sales,
    CONCAT(ROUND((total_sales/overall_sales) * 100,2),'%') AS contribution
FROM(
	SELECT 
		dc.category AS category,
		SUM(fs.sales_amount) AS total_sales,
		SUM(SUM(fs.sales_amount))OVER() AS overall_sales
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_products AS dc
	ON fs.product_number = dc.product_number
	GROUP BY dc.category
)t
ORDER BY ROUND((total_sales/overall_sales) * 100,2) DESC;


/*5) Data Segmentation
	Group the data based on a specific range
    Understand relation between two measures*/

SELECT 
	cost_range,
    COUNT(product_number) AS total_products
FROM(
	SELECT
		product_number,
		product_name,
		product_cost,
		CASE
			WHEN product_cost<100 THEN 'Below 100'
			WHEN product_cost BETWEEN 100 AND 500 THEN '100-500'
			WHEN product_cost BETWEEN 500 AND 1000 THEN '500-100'
			ELSE 'Above 1000'
		END AS cost_range
	FROM gold.dim_products
)t
GROUP BY cost_range
ORDER BY total_products;

SELECT 
	customer_segment,
    COUNT(customer_number) AS total_customers
FROM(
	SELECT 
		customer_number,
		CASE 
			WHEN order_range>=12 AND total_sales>5000 THEN 'VIP'
			WHEN order_range>=12 AND total_sales<=5000 THEN 'Regular'
			ELSE 'New'
		END AS customer_segment
	FROM(
		SELECT
			customer_number,
			SUM(sales_amount) AS total_sales,
			MIN(order_date) AS first_order,
			MAX(order_date) AS last_order,
			TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date )) AS order_range
		FROM gold.fact_sales
		GROUP BY customer_number
	)t
)u
GROUP BY customer_segment
ORDER BY total_customers;

/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================


CREATE VIEW gold.report_customers AS (

	WITH base_query AS(
	/*---------------------------------------------------------------------------
	1) Base Query: Retrieves core columns from tables
	---------------------------------------------------------------------------*/
	SELECT
	f.order_number,
	f.product_number,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_number,
	c.customer_key,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	TIMESTAMPDIFF(year, c.birth_date, NOW()) age
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON c.customer_number = f.customer_number
	WHERE order_date IS NOT NULL)

	, customer_aggregation AS (
	/*---------------------------------------------------------------------------
	2) Customer Aggregations: Summarizes number metrics at the customer level
	---------------------------------------------------------------------------*/
	SELECT 
		customer_number,
		customer_key,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT product_number) AS total_products,
		MAX(order_date) AS last_order_date,
		TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
	FROM base_query
	GROUP BY 
		customer_number,
		customer_key,
		customer_name,
		age
	)
	SELECT
	customer_number,
	customer_key,
	customer_name,
	age,
	CASE 
		 WHEN age < 20 THEN 'Under 20'
		 WHEN age between 20 and 29 THEN '20-29'
		 WHEN age between 30 and 39 THEN '30-39'
		 WHEN age between 40 and 49 THEN '40-49'
		 ELSE '50 and above'
	END AS age_group,
	CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,
	last_order_date,
	TIMESTAMPDIFF(month, last_order_date, NOW()) AS recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products
	lifespan,
	-- Compuate average order value (AVO)
	CASE WHEN total_sales = 0 THEN 0
		 ELSE total_sales / total_orders
	END AS avg_order_value,
	-- Compuate average monthly spend
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales / lifespan
	END AS avg_monthly_spend
	FROM customer_aggregation
);



/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================


CREATE VIEW gold.report_products AS(

	WITH base_query AS (
	/*---------------------------------------------------------------------------
	1) Base Query: Retrieves core columns from fact_sales and dim_products
	---------------------------------------------------------------------------*/
		SELECT
			f.order_number,
			f.order_date,
			f.customer_number,
			f.sales_amount,
			f.quantity,
			p.product_number,
			p.product_name,
			p.category,
			p.subcategory,
			p.product_cost
		FROM gold.fact_sales f
		LEFT JOIN gold.dim_products p
			ON f.product_number = p.product_number
		WHERE order_date IS NOT NULL  -- only consider valid sales dates
	),

	product_aggregations AS (
	/*---------------------------------------------------------------------------
	2) Product Aggregations: Summarizes key metrics at the product level
	---------------------------------------------------------------------------*/
	SELECT
		product_number,
		product_name,
		category,
		subcategory,
		product_cost,
		TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
		MAX(order_date) AS last_sale_date,
		COUNT(DISTINCT order_number) AS total_orders,
		COUNT(DISTINCT customer_number) AS total_customers,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
	FROM base_query

	GROUP BY
		product_number,
		product_name,
		category,
		subcategory,
		product_cost
	)

	/*---------------------------------------------------------------------------
	3) Final Query: Combines all product results into one output
	---------------------------------------------------------------------------*/
	SELECT 
		product_number,
		product_name,
		category,
		subcategory,
		product_cost,
		last_sale_date,
		TIMESTAMPDIFF(MONTH, last_sale_date, NOW()) AS recency_in_months,
		CASE
			WHEN total_sales > 50000 THEN 'High-Performer'
			WHEN total_sales >= 10000 THEN 'Mid-Range'
			ELSE 'Low-Performer'
		END AS product_segment,
		lifespan,
		total_orders,
		total_sales,
		total_quantity,
		total_customers,
		avg_selling_price,
		-- Average Order Revenue (AOR)
		CASE 
			WHEN total_orders = 0 THEN 0
			ELSE total_sales / total_orders
		END AS avg_order_revenue,

		-- Average Monthly Revenue
		CASE
			WHEN lifespan = 0 THEN total_sales
			ELSE total_sales / lifespan
		END AS avg_monthly_revenue

	FROM product_aggregations 
);