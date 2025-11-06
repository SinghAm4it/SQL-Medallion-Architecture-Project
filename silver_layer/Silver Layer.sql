-- In Silver layer we will inserst the cleaned, standardized and normalized data
-- Here we will transform and load the bronze layer
-- We can add meta data columns that are not in the source data but we are adding it to
-- see some extra details

CREATE TABLE silver.crm_cust_info(
	cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
	cst_gender NVARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME DEFAULT NOW()
);

CREATE TABLE silver.crm_prd_info(
	prd_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_name NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);

CREATE TABLE silver.crm_sales_details(
	sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

CREATE TABLE silver.erp_cust_az12(
	cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(40)
);

CREATE TABLE silver.erp_loc_a101(
	cid NVARCHAR(50),
    cntry NVARCHAR(50)
);

CREATE TABLE silver.erp_px_cat_g1v2(
	id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(40)
);

/* -- CLEANING DATA

DELIMITER //
CREATE PROCEDURE load_silver_layer()
BEGIN 
	-- Table 1 crm_cust_info
	TRUNCATE TABLE silver.crm_cust_info;
	INSERT INTO silver.crm_cust_info()
		SELECT 
			cst_id,
			cst_key,
			COALESCE(TRIM(cst_firstname),'Unknown') AS cst_firstname,
			COALESCE(TRIM(cst_lastname),'Unknown') AS cst_lastname,
			CASE 
				WHEN UPPER(cst_marital_status) = 'M' THEN 'Married'
				WHEN UPPER(cst_marital_status) = 'S' THEN 'Single'
				ELSE 'N/A'
			END AS cst_marital_status,
			CASE 
				WHEN UPPER(cst_gender) = 'F' THEN 'Female'
				WHEN UPPER(cst_gender) = 'M' THEN 'Male'
				ELSE 'N/A'
			END AS cst_gender,
			cst_create_date,
			NOW()
		FROM(
			SELECT 
				*,
				ROW_NUMBER()OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS row_num
			FROM bronze.crm_cust_info
		)t
		WHERE row_num = 1;

	-- Table 2 crm_prd_info
	TRUNCATE TABLE silver.crm_prd_info;
	INSERT INTO silver.crm_prd_info()
		SELECT 
			prd_id,
			prd_key,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
			SUBSTRING(prd_key,7,LENGTH(prd_key)) AS sales_prd_key,
			TRIM(prd_name) AS prd_name,
			prd_cost,
			CASE 
				WHEN UPPER(prd_line) = 'M' THEN 'Mountain'
				WHEN UPPER(prd_line) = 'R' THEN 'Road'
				WHEN UPPER(prd_line) = 'T' THEN 'Touring'
				WHEN UPPER(prd_line) = 'S' THEN 'Other Sales'
				ELSE 'N/A'
			END AS prd_line,
			prd_start_dt,
			DATE_SUB(LEAD(prd_start_dt)OVER(PARTITION BY prd_key ORDER BY prd_start_dt),INTERVAL 1 DAY) AS prd_end_dt,
			NOW()
		FROM bronze.crm_prd_info;

	-- Table 3 crm_sales_details
	TRUNCATE TABLE silver.crm_sales_details;
	INSERT INTO silver.crm_sales_details()
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS CHAR(50)) AS DATE) 
			END AS sls_order_dt,
				CASE 
				WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS CHAR(50)) AS DATE)
			END AS sls_ship_dt,
				CASE 
				WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS CHAR(50)) AS DATE)
			END AS sls_due_dt,
				CASE 
				WHEN sls_sales IS NULL OR sls_sales <= 0 THEN sls_quantity*ABS(sls_price)
				WHEN sls_sales != sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 THEN ROUND(sls_sales/sls_quantity,0)
				ELSE sls_price
			END AS sls_price,
			NOW()
		FROM bronze.crm_sales_details;
		
	-- Table 4 erp_cust_az12
	TRUNCATE TABLE silver.erp_cust_az12;
	INSERT INTO silver.erp_cust_az12()	
		SELECT 
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))
				ELSE cid
			END AS cid,
			CASE 
				WHEN bdate > NOW() THEN NULL
				ELSE bdate
			END AS bdate,
			CASE 
				WHEN UPPER(gen) = 'M' THEN 'Male'
				WHEN UPPER(gen) = 'F' THEN 'Female'
				WHEN gen IS NULL THEN 'N/A'
				ELSE gen
			END AS gen,
			NOW()
		FROM bronze.erp_cust_az12;
		
	-- Table 5 erp_loc_a101
	TRUNCATE TABLE silver.erp_loc_a101;
	INSERT INTO erp_loc_a101()
		SELECT
			REPLACE(cid,'-','') AS cid,
			CASE 
				WHEN UPPER(TRIM(REPLACE(cntry,'\r',''))) = 'DE' THEN 'Germany'
				WHEN UPPER(TRIM(REPLACE(cntry,'\r',''))) IN ('US','USA') THEN 'United States'
				WHEN UPPER(TRIM(REPLACE(cntry,'\r',''))) = '' OR cntry IS NULL THEN 'N/A'
				ELSE TRIM(REPLACE(cntry,'\r',''))
			END AS cntry,
			NOW()
		FROM bronze.erp_loc_a101;
		
	-- Table 6 erp_px_cata_g1v2
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	INSERT INTO silver.erp_px_cat_g1v2()
		SELECT 
			id,
			cat,
			subcat,
			TRIM(REPLACE(maintenance,'\r','')) AS maintenance,
			NOW()
		FROM bronze.erp_px_cat_g1v2;
END//    
DELIMITER ;  */    		
CALL load_silver_layer();