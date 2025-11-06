-- Dimension Table formation
-- 1) Customers
SELECT
	ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gender,
    ci.cst_create_date,
    ca.bdate,
    ca.gen,
    la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid;

SELECT DISTINCT
	ci.cst_gender,
    ca.gen,
	CASE
		WHEN ci.cst_gender != 'N/A' THEN ci.cst_gender
		ELSE COALESCE(ca.gen,'N/A')
	END AS new_gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid;

-- Make Surrogate Key
-- An artificial key that uniquely identifies each row, no business meaning 
SELECT *,ROW_NUMBER()OVER(ORDER BY ci.cst_id)
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid;

-- 2) Products
-- Remove Historical Date only consider current products
SELECT sales_prd_key,COUNT(*) FROM(
	SELECT 
		pi.prd_id,
		pi.prd_key,
		pi.cat_id,
		pi.sales_prd_key,
		pi.prd_name,
		pi.prd_cost,
		pi.prd_line,
		pi.prd_start_dt,
		pi.prd_end_dt,
		pa.cat,
		pa.subcat,
		pa.maintenance
	FROM silver.crm_prd_info AS pi
	LEFT JOIN silver.erp_px_cat_g1v2 AS pa
	ON pi.cat_id = pa.id
	WHERE prd_end_dt IS NULL
)t
GROUP BY sales_prd_key
HAVING COUNT(*)>1;

SELECT DISTINCT cat_id
FROM silver.crm_prd_info AS pi
	LEFT JOIN silver.erp_px_cat_g1v2 AS pa
	ON pi.cat_id = pa.id
	WHERE prd_end_dt IS NULL;
SELECT DISTINCT cat
FROM silver.crm_prd_info AS pi
	LEFT JOIN silver.erp_px_cat_g1v2 AS pa
	ON pi.cat_id = pa.id
	WHERE prd_end_dt IS NULL;
SELECT DISTINCT subcat
FROM silver.crm_prd_info AS pi
	LEFT JOIN silver.erp_px_cat_g1v2 AS pa
	ON pi.cat_id = pa.id
	WHERE prd_end_dt IS NULL;
SELECT DISTINCT maintenance
    FROM silver.crm_prd_info AS pi
	LEFT JOIN silver.erp_px_cat_g1v2 AS pa
	ON pi.cat_id = pa.id
	WHERE prd_end_dt IS NULL;
    
    
-- Fact table Sales
SELECT *
FROM silver.crm_sales_details AS csd
LEFT JOIN gold.dim_customers AS cu
ON csd.sls_cust_id = cu.customer_id
LEFT JOIN gold.dim_products AS pr
ON csd.sls_prd_key = pr.product_key
WHERE pr.product_key IS NULL OR cu.customer_id IS NULL;