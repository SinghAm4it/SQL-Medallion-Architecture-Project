-- Data Modelling 
-- making models / er diagram for database of how the tables are connected
-- 3 Types
-- 1) Conceptual contains only tables names and connection between them through simple lines
-- 2) Logical contains column names, pk and fk details of which columns are connected 
-- 3) Physical contains the datatypes of columns

-- Star schema (data model)
-- IN middle fact table and In outer dimensions
-- Snowflake schema (data model)
-- In middle fact table and In outer dimensions but that dimensions are also divided into subdimensions

-- Dimensions table contain descriptive information
-- Fact table contains numbers, ids and dates 

-- Dimension Customers
CREATE OR REPLACE VIEW gold.dim_customers AS(
	SELECT
		ROW_NUMBER()OVER(ORDER BY ci.cst_id) AS customer_number,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_key,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		la.cntry AS country,
		ci.cst_marital_status AS marital_status,
		CASE
			WHEN ci.cst_gender != 'N/A' THEN ci.cst_gender
			ELSE COALESCE(ca.gen,'N/A')
		END AS gender,
		ca.bdate AS birth_date,
		ci.cst_create_date AS create_date
	FROM silver.crm_cust_info AS ci
	LEFT JOIN silver.erp_cust_az12 AS ca
	ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 AS la
	ON ci.cst_key = la.cid
);	  

-- Dimension Product
CREATE OR REPLACE VIEW gold.dim_products AS (
	SELECT 
		ROW_NUMBER()OVER(ORDER BY pi.prd_id) AS product_number,
		pi.prd_id AS product_id,
		pi.sales_prd_key AS product_key,
		pi.cat_id AS category_id,
		CASE 
			WHEN pi.cat_id LIKE 'AC%' THEN 'Accessories'
			WHEN pi.cat_id LIKE 'BI%' THEN 'Bikes'
			WHEN pi.cat_id LIKE 'CL%' THEN 'Clothing'
			WHEN pi.cat_id LIKE 'CO%' THEN 'Components'
			ELSE 'N/A'
		END AS category,
		COALESCE(pa.subcat,'N/A') AS subcategory,
		COALESCE(pa.maintenance,'N/A') AS maintenance,
		pi.prd_name AS product_name,
		pi.prd_cost AS product_cost,
		pi.prd_line AS product_line,
		pi.prd_start_dt AS product_start_dt
	FROM silver.crm_prd_info AS pi
	LEFT JOIN silver.erp_px_cat_g1v2 AS pa
	ON pi.cat_id = pa.id
	WHERE prd_end_dt IS NULL
);

-- Fact Sales
CREATE OR REPLACE VIEW gold.fact_sales AS (
	SELECT 	
		csd.sls_ord_num AS order_number,
        pr.product_number AS product_number,
        cu.customer_number AS customer_number,
        csd.sls_order_dt AS order_date,
        csd.sls_ship_dt AS shipping_date,
        csd.sls_due_dt AS due_date,
        csd.sls_sales AS sales_amount,
        csd.sls_quantity AS quantity,
		csd.sls_price AS price
	FROM silver.crm_sales_details AS csd
    LEFT JOIN gold.dim_customers AS cu
    ON csd.sls_cust_id = cu.customer_id
    LEFT JOIN gold.dim_products AS pr
    ON csd.sls_prd_key = pr.product_key
);
    
    