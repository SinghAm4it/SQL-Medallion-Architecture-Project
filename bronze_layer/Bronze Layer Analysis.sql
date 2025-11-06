-- First anaysis the tables from bronze layer and then transform them to silver layer


-- Table 1 crm_cust_info
/*See If any of the primary key has duplicate or any null value
Remove duplicate values*/
SELECT 
	cst_id,
    COUNT(*) 
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1;

/*Check if strings have any leading or trailing spaces
Removed Unwanted characters*/
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
SELECT cst_key
FROM bronze.crm_cust_info
WHERE cst_key!= TRIM(cst_key);

/*Check the values that can be enum of have limited values 
This is Data Normalization where coded value is written as user friendly values
We have also handled nulls*/
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;
SELECT DISTINCT cst_gender
FROM bronze.crm_cust_info;

-- Table 2 crm_prd_info
/* First we will remove duplicates from primary key*/
SELECT 
	prd_id,
    COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

/* Removing Unwanted Characters and spaces*/
SELECT prd_name
FROM bronze.crm_prd_info
WHERE prd_name != TRIM(prd_name);
SELECT prd_key
FROM bronze.crm_prd_info
WHERE prd_key != TRIM(prd_key);
SELECT prd_line
FROM bronze.crm_prd_info
WHERE prd_line != TRIM(prd_line);

/*Data Normalization*/
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;

/*Date Handling
Here Start Date is higher 
Thus we will define End date by ourself which will we next start date-1 */
SELECT *
FROM bronze.crm_prd_info
WHERE prd_start_dt < prd_end_dt;
SELECT 
	prd_start_dt,
    prd_end_dt,
    LEAD(prd_start_dt)OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS prd_end_dt_test,
    DATE_SUB(LEAD(prd_start_dt)OVER(PARTITION BY prd_key ORDER BY prd_start_dt),INTERVAL 1 DAY) tst
FROM bronze.crm_prd_info;
    
-- Table 3 crm_sales_details
/*Checking any sales that can't be linked with customers or products table*/ 
SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT sales_prd_key FROM silver.crm_prd_info);
SELECT *
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

/*Converting INT to DATE AND date Handling*/
SELECT 
	sls_order_dt,
    CAST(CAST(sls_order_dt AS CHAR(40)) AS DATE)
FROM bronze.crm_sales_details
WHERE LENGTH(sls_order_dt) = 0 AND LENGTH(sls_order_dt) !=8;
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt>sls_ship_dt OR sls_order_dt>sls_due_dt;

/*Removing negative or null values from sales, quantity and price
And Wrong Calculations (sales = quantity*price)*/
SELECT DISTINCT *
FROM bronze.crm_sales_details
WHERE sls_quantity IS NULL OR sls_quantity<=0 OR sls_sales IS NULL 
	OR sls_sales<=0 OR sls_price IS NULL OR sls_price<=0 
	OR sls_sales != sls_quantity*sls_price;
    
-- Table 4 erp_cust_az12
/*Data Standardization to make its relational diagram with another tables*/
SELECT cid,
	COUNT(*)
FROM bronze.erp_cust_az12 
GROUP BY cid
HAVING COUNT(*)>1;
SELECT cid FROM bronze.erp_cust_az;
SELECT cst_key FROM silver.crm_cust_info;

/*NULL value analysis*/
SELECT cid FROM bronze.erp_cust_az12 WHERE cid IS NULL;
SELECT bdate FROM bronze.erp_cust_az12 WHERE bdate IS NULL;
SELECT cid,gen FROM bronze.erp_cust_az12 WHERE gen IS NULL;

/*Removing Unwanted characters*/
SELECT cid FROM bronze.erp_cust_az12 WHERE cid != TRIM(cid);
SELECT gen FROM bronze.erp_cust_az12 WHERE gen != TRIM(gen);

/*Checking Authenticity of bdate and gen*/
SELECT bdate FROM bronze.erp_cust_az12 WHERE bdate < '1924-01-01' 
											OR bdate>NOW();
SELECT DISTINCT gen FROM bronze.erp_cust_az12;

-- Table 5 erp_loc_a101
/*Null Handling and Mapping cid with cst_key and removing 
unwanted characters*/
SELECT * FROM bronze.erp_loc_a101 WHERE cid IS NULL OR cntry IS NULL;
SELECT * FROM silver.crm_cust_info;

/*Checking any unwanted characters and hidden characters and 
Also Data Normalization*/
SELECT * FROM bronze.erp_loc_a101 WHERE cid != TRIM(cid);
SELECT * FROM bronze.erp_loc_a101 WHERE cntry != TRIM(cntry);
SELECT DISTINCT TRIM(cntry) FROM bronze.erp_loc_a101;
-- This have hidden \r  character 
SELECT DISTINCT HEX(cntry), cntry FROM bronze.erp_loc_a101; 
SELECT DISTINCT UPPER(TRIM(REPLACE(cntry,'\r',''))) AS cleaned_cntry 
FROM bronze.erp_loc_a101
WHERE UPPER(TRIM(REPLACE(cntry,'\r','')))  = 'DE';

-- Table 6 erp_px_cat_g1v2
/*Checking unwanted or hidden characters*/ 
SELECT * FROM bronze.erp_px_cat_g1v2 WHERE id != TRIM(id);
SELECT * FROM bronze.erp_px_cat_g1v2 WHERE cat != TRIM(cat);
SELECT * FROM bronze.erp_px_cat_g1v2 WHERE subcat != TRIM(subcat);
SELECT * FROM bronze.erp_px_cat_g1v2 WHERE maintenance != TRIM(maintenance);
SELECT * FROM bronze.erp_px_cat_g1v2 WHERE id IS NULL 
										OR cat IS NULL
                                        OR subcat IS NULL
                                        OR maintenance IS NULL;
SELECT * FROM bronze.erp_px_cat_g1v2 WHERE id = '' 
										OR cat = ''
                                        OR subcat = ''
                                        OR maintenance = '';
SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT subcat FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT cat FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT TRIM(REPLACE(maintenance,'\r', '')) FROM bronze.erp_px_cat_g1v2;