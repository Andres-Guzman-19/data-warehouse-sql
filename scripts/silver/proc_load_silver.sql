/*
CREAR PROCEDIMIENTO ALMACENADO PARA CARGAR LOS DATOS A LAS TABLAS DE LA CAPA SILVER
-----------------------------------------------------

PROPOSITO:
	El procedimiento almacenado carga los datos de las tablas de la capa bromze a las tablas de la capa silver.
	Se elimina todo el contenido de la tabla para cargar nuevamente los datos

TRANSFORMACIONES IMPORTANTES:
	- crm_cust_info: En caso de valores duplicados se mantiene el ultimo de acuerdo a la columna fecha cst_create_date
	- crm_prd_info:
		- Se modifica la columna prd_end_dt de acuerdo con el siguiente valor de la columna prd_start_dt
		- Se crean las columnas cat_id, prd_key de acuerdo con la columna prd_key
	- crm_sales_details:
		- Si las columnas sls_order_dt, sls_ship_dt, sls_due_dtson 0 o el numero de caracteres es diferente a 8 queda vacia
		- Si sls_sales es NULL, menor a 0 o no corresponde al calculo: sls_quantity * sls_price se realiza el calculo sls_quantity * sls_price
		- Si sls_price es menor a 0 o NULL se calcula: sls_sales / sls_quantity
	- erp_cust_az12: si bdate es mayor a la fecha actual queda NULL

PARAMETROS
	None

 EJEMPLO DE USO
	EXEC silver.load_silver;
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_time_layer DATETIME, @end_time_layer DATETIME;
	BEGIN TRY
		SET @start_time_layer = GETDATE();
		PRINT '============================================';
		PRINT 'Cargando la capa silver';
		PRINT '============================================';

		PRINT '--------------------------------------------';
		PRINT 'Cargando tablas CRM';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> truncate en tabla crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;

		PRINT '>> Insertando datos en: crm_cust_info';
		WITH limpiar_crm_cust_info AS (
			SELECT
			   [cst_id]
			  ,[cst_key]
			  ,TRIM(UPPER([cst_firstname])) [cst_firstname]
			  ,TRIM(UPPER([cst_lastname])) [cst_lastname]
			  ,CASE WHEN TRIM(UPPER([cst_material_status])) = 'S' THEN 'Single'
					WHEN TRIM(UPPER([cst_material_status])) = 'M' THEN 'Married'
					ELSE 'n/a' 
			  END [cst_material_status]
			  ,CASE WHEN TRIM(UPPER([cst_gndr])) = 'F' THEN 'Female'
					WHEN TRIM(UPPER([cst_gndr])) = 'M' THEN 'Male'
					ELSE 'n/a' 
				END [cst_gndr]
			  ,[cst_create_date],
				ROW_NUMBER() OVER(PARTITION BY [cst_id] ORDER BY [cst_create_date] DESC) AS marca_ultimo
			FROM
				bronze.crm_cust_info
		)
		INSERT INTO silver.crm_cust_info (
			[cst_id]
		   ,[cst_key]
		   ,[cst_firstname]
		   ,[cst_lastname]
		   ,[cst_material_status]
		   ,[cst_gndr]
		   ,[cst_create_date])
		SELECT
			[cst_id]
		   ,[cst_key]
		   ,[cst_firstname]
		   ,[cst_lastname]
		   ,[cst_material_status]
		   ,[cst_gndr]
		   ,[cst_create_date]
		FROM limpiar_crm_cust_info
		WHERE marca_ultimo = 1 AND cst_id IS NOT NULL;

		SET @end_time = GETDATE();
		PRINT '>> Tiempo de carga: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> truncate en tabla crm_prd_info';

		TRUNCATE TABLE silver.crm_prd_info;

		PRINT '>> Insertando datos en: crm_prd_info';
		INSERT INTO silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			[prd_id],
			REPLACE(SUBSTRING([prd_key], 1,5),'-', '_') cat_id,
			SUBSTRING([prd_key], 7,LEN([prd_key])) prd_key,
			[prd_nm],
			ISNULL([prd_cost],0) prd_cost,
			CASE UPPER(TRIM([prd_line]))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END prd_line,
			CAST([prd_start_dt] AS DATE),
			CAST(LEAD([prd_start_dt]) OVER (PARTITION BY [prd_key] ORDER BY [prd_start_dt]) - 1 AS DATE) [prd_end_dt]
		FROM [DataWarehouse].[bronze].[crm_prd_info];

		SET @end_time = GETDATE();
		PRINT '>> Tiempo de carga: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> truncate en tabla crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT '>> Insertando datos en: crm_sales_details';
		INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			[sls_ord_num],
			[sls_prd_key],
			[sls_cust_id],
			CASE WHEN [sls_order_dt] = 0 OR LEN([sls_order_dt]) != 8 THEN NULL
				ELSE CAST(CAST([sls_order_dt] AS VARCHAR) AS DATE)
			END sls_order_dt,
			CASE WHEN [sls_ship_dt] = 0 OR LEN([sls_ship_dt]) != 8 THEN NULL
				ELSE CAST(CAST([sls_ship_dt] AS VARCHAR) AS DATE)
			END [sls_ship_dt],
			CASE WHEN [sls_due_dt] = 0 OR LEN([sls_due_dt]) != 8 THEN NULL
				ELSE CAST(CAST([sls_due_dt] AS VARCHAR) AS DATE)
			END [sls_due_dt],
			CASE WHEN [sls_sales] IS NULL OR [sls_sales] <= 0 OR [sls_sales] != [sls_quantity] * ABS([sls_price])
				THEN [sls_quantity] * ABS([sls_price])
				ELSE [sls_sales]
			END [sls_sales],
			[sls_quantity],
			CASE WHEN [sls_price] <= 0 OR [sls_price] IS NULL
				THEN [sls_sales] / NULLIF([sls_quantity],0)
				ELSE [sls_price]
			END [sls_price]
		FROM [DataWarehouse].[bronze].[crm_sales_details];

		SET @end_time = GETDATE();
		PRINT '>> Tiempo de carga: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------------';

		PRINT '--------------------------------------------';
		PRINT 'Cargando tablas ERP';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> truncate en tabla erp_cust_az12';

		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT '>> Insertando datos en: erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		SELECT
			CASE WHEN [cid] LIKE 'NAS%' THEN SUBSTRING([cid], 4, LEN([cid]))
				ELSE [cid]
			END [cid],
			CASE WHEN [bdate] > GETDATE() THEN NULL
				ELSE [bdate]
			END [bdate],
			CASE WHEN TRIM(UPPER([gen])) IN ('F', 'FEMALE') THEN 'Female'
				WHEN TRIM(UPPER([gen])) IN ('M', 'MALE') THEN 'Male'
				ELSE [gen]
			END [gen]
		FROM [DataWarehouse].[bronze].[erp_cust_az12];

		SET @end_time = GETDATE();
		PRINT '>> Tiempo de carga: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> truncate en tabla erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;

		PRINT '>> Insertando datos en: erp_loc_a101';
		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
		)
		SELECT
			REPLACE(cid, '-', '') cid,
			CASE WHEN TRIM(UPPER(cntry)) = 'DE' THEN 'Germany'
				WHEN TRIM(UPPER(cntry)) IN ('US', 'USA') THEN 'United Sates'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END cntry
		FROM bronze.erp_loc_a101;

		SET @end_time = GETDATE();
		PRINT '>> Tiempo de carga: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> truncate en tabla erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		PRINT '>> Insertando datos en: erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;

		SET @end_time = GETDATE();
		PRINT '>> Tiempo de carga: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------------';
		SET @end_time_layer = GETDATE();
		PRINT 'Carga de la capa silver completa'
		PRINT '>> Tiempo de carga de la capa silver: ' + CAST (DATEDIFF(second, @start_time_layer, @end_time_layer) AS NVARCHAR) + ' segundos';
	END TRY
	BEGIN CATCH
		PRINT '===================================================';
		PRINT 'OCURRIO UN ERROR DURANTE LA CARGA DE LA CAPA SILVER';
		PRINT 'ERROR: ' + ERROR_MESSAGE();
		PRINT 'ERROR: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR: ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '===================================================';
	END CATCH
END