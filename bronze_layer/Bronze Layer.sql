-- Create Layers For ETL
CREATE DATABASE bronze;
CREATE DATABASE silver;
CREATE DATABASE gold;

-- Load Data In bronze layer
-- In bronze layer we will insert the data as it as like in the source

CREATE TABLE bronze.crm_cust_info(
	cst_id NVARCHAR(20),
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
	cst_gender NVARCHAR(50),
    cst_create_date NVARCHAR(50)
);

CREATE TABLE bronze.crm_prd_info(
	prd_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_name NVARCHAR(50),
    prd_cost NVARCHAR(40),
    prd_line NVARCHAR(50),
    prd_start_dt NVARCHAR(40),
    prd_end_dt NVARCHAR(40)
);


CREATE TABLE bronze.crm_sales_details(
	sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id NVARCHAR(50),
    sls_order_dt NVARCHAR(50),
    sls_ship_dt NVARCHAR(50),
    sls_due_dt NVARCHAR(50),
    sls_sales NVARCHAR(50),
    sls_quantity NVARCHAR(50),
    sls_price NVARCHAR(50)
);

CREATE TABLE bronze.erp_cust_az12(
	cid NVARCHAR(50),
    bdate NVARCHAR(50),
    gen NVARCHAR(40)
);

CREATE TABLE bronze.erp_loc_a101(
	cid NVARCHAR(50),
    cntry NVARCHAR(50)
);

CREATE TABLE bronze.erp_px_cat_g1v2(
	id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(40)
);

SHOW VARIABLES LIKE 'secure_file_priv';

-- Create Procedure For It so that we don't have to do it everytime

/*Now Insert data into tables
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(prd_id, prd_key, prd_name, prd_cost, prd_line, prd_start_dt, prd_end_dt);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gender, cst_create_date);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales,sls_quantity,sls_price);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_az12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(cid,bdate,gen);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/loc_a101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(cid,cntry);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/px_cat_g1v2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,cat,subcat,maintenance); */

-- First change the empty strings to null
/*DELIMITER //
CREATE PROCEDURE updating_empty_strings()
BEGIN
	UPDATE `bronze`.`crm_cust_info`
	SET
	`cst_id` = NULLIF(cst_id,''),
	`cst_key` = NULLIF(cst_key,''),
	`cst_firstname` = NULLIF(cst_firstname,''),
	`cst_lastname` = NULLIF(cst_lastname,''),
	`cst_marital_status` = NULLIF(cst_marital_status,''),
	`cst_gender` = NULLIF(cst_gender,''),
	`cst_create_date` = NULLIF(cst_create_date,'');

	UPDATE `bronze`.`crm_prd_info`
	SET
	`prd_id` = NULLIF(prd_id,''),
	`prd_key` = NULLIF(prd_key,''),
	`prd_name` = NULLIF(prd_name,''),
	`prd_cost` = NULLIF(prd_cost,''),
	`prd_line` = NULLIF(prd_line,''),
	`prd_start_dt` = NULLIF(prd_start_dt,''),
	`prd_end_dt` = NULLIF(prd_end_dt,'');

	UPDATE `bronze`.`crm_sales_details`
	SET
	`sls_ord_num` = NULLIF(sls_ord_num,''),
	`sls_prd_key` = NULLIF(sls_prd_key,''),
	`sls_cust_id` = NULLIF(sls_cust_id,''),
	`sls_order_dt` = NULLIF(sls_order_dt,''),
	`sls_ship_dt` = NULLIF(sls_ship_dt,''),
	`sls_due_dt` = NULLIF(sls_due_dt,''),
	`sls_sales` = NULLIF(sls_sales,''),
	`sls_quantity` = NULLIF(sls_quantity,''),
	`sls_price` = NULLIF(sls_price,'');

	UPDATE `bronze`.`erp_cust_az12`
	SET
	`cid` = NULLIF(cid,''),
	`bdate` = NULLIF(bdate,''),
	`gen` = NULLIF(gen,'');

	UPDATE `bronze`.`erp_loc_a101`
	SET
	`cid` = NULLIF(cid,''),
	`cntry` = NULLIF(cntry,'');

	UPDATE `bronze`.`erp_px_cat_g1v2`
	SET
	`id` = NULLIF(id,''),
	`cat` = NULLIF(cat,''),
	`subcat` = NULLIF(subcat,''),
	`maintenance` = NULLIF(maintenance,'');
END//
DELIMITER ;*/
-- CALL updating_empty_strings();

-- Then alter the datatype of columns 
/*DELIMITER //
CREATE PROCEDURE change_to_original_datatype()
BEGIN
	ALTER TABLE bronze.crm_cust_info
	MODIFY COLUMN cst_id INT NULL,
	MODIFY COLUMN cst_create_date DATE NULL;

	ALTER TABLE bronze.crm_prd_info
	MODIFY COLUMN prd_id INT NULL,
	MODIFY COLUMN prd_cost INT NULL,
	MODIFY COLUMN prd_start_dt DATE NULL,
	MODIFY COLUMN prd_end_dt DATE NULL;

	ALTER TABLE bronze.crm_sales_details
	MODIFY COLUMN sls_cust_id INT NULL,
	MODIFY COLUMN sls_order_dt INT NULL,
	MODIFY COLUMN sls_ship_dt INT NULL,
	MODIFY COLUMN sls_due_dt INT NULL,
	MODIFY COLUMN sls_sales INT NULL,
	MODIFY COLUMN sls_quantity INT NULL,
	MODIFY COLUMN sls_price INT NULL;

	ALTER TABLE erp_cust_az12
	MODIFY COLUMN bdate DATE NULL;
END//
DELIMITER ;*/
-- CALL change_to_original_datatype();

/* Truncate Data Before Updating
TRUNCATE TABLE bronze.crm_cust_info;
TRUNCATE TABLE bronze.crm_prd_info;
TRUNCATE TABLE bronze.crm_sales_details;
TRUNCATE TABLE bronze.erp_cust_az12;
TRUNCATE TABLE bronze.erp_loc_a101;
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
*/

-- When updating the data use this procedure to change the datatype to varchar  
/*DELIMITER //
CREATE PROCEDURE change_to_nvarchar()
BEGIN
	ALTER TABLE bronze.crm_cust_info
	MODIFY COLUMN cst_id NVARCHAR(50) NULL,
	MODIFY COLUMN cst_create_date NVARCHAR(50) NULL;

	ALTER TABLE bronze.crm_prd_info
	MODIFY COLUMN prd_id NVARCHAR(50) NULL,
	MODIFY COLUMN prd_cost NVARCHAR(50) NULL,
	MODIFY COLUMN prd_start_dt NVARCHAR(50) NULL,
	MODIFY COLUMN prd_end_dt NVARCHAR(50) NULL;

	ALTER TABLE bronze.crm_sales_details
	MODIFY COLUMN sls_cust_id NVARCHAR(50) NULL,
	MODIFY COLUMN sls_order_dt NVARCHAR(50) NULL,
	MODIFY COLUMN sls_ship_dt NVARCHAR(50) NULL,
	MODIFY COLUMN sls_due_dt NVARCHAR(50) NULL,
	MODIFY COLUMN sls_sales NVARCHAR(50) NULL,
	MODIFY COLUMN sls_quantity NVARCHAR(50) NULL,
	MODIFY COLUMN sls_price NVARCHAR(50) NULL;

	ALTER TABLE erp_cust_az12
	MODIFY COLUMN bdate NVARCHAR(50) NULL;
END//
DELIMITER ;*/
-- CALL change_to_nvarchar();


