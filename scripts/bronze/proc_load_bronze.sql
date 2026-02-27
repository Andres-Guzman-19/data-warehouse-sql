/*
CREAR PROCEDIMIENTO ALMACENADO PARA CARGAR LOS DATOS A LAS TABLAS DE LA CAPA BRONZE
-----------------------------------------------------

PROPOSITO:
	El procedimiento almacenado carga los datos del csv a las tablas de la capa bronze.
	Se elimina todo el contenido de la tabla para cargar nuevamente los datos (TRUNCATE BULK INSERT)

PARAMETROS
	None

 EJEMPLO DE USO
	EXEC bronze.load_bronze;
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_time_layer DATETIME, @end_time_layer DATETIME;
	BEGIN TRY
		SET @start_time_layer = GETDATE();
		PRINT '============================================';
		PRINT 'Cargando la capa bronze';
		PRINT '============================================';

		PRINT '--------------------------------------------';
		PRINT 'Cargando tablas CRM';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> truncate en tabla bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Insertando datos en: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Andres\Documents\Analisis de datos\SQL\data-warehouse-sql\datasets\source_crm\cust_info.csv'
		WITH(
			FIRSTROW = 2, --Toma desde la segunda fila (La primera es el encabezado)
			FIELDTERMINATOR = ',',
			TABLOCK --Bloquea la tabla
		);
		SET @end_time = GETDATE();
		PRINT '>> Tiempo de carga: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> truncate en tabla crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Insertando datos en: crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Andres\Documents\Analisis de datos\SQL\data-warehouse-sql\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Tiempo de carga: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> truncate en tabla crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Insertando datos en: crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Andres\Documents\Analisis de datos\SQL\data-warehouse-sql\datasets\source_crm\sales_details.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Tiempo de carga: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------------';

		PRINT '--------------------------------------------';
		PRINT 'Cargando tablas ERP';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> truncate en tabla bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Insertando datos en: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Andres\Documents\Analisis de datos\SQL\data-warehouse-sql\datasets\source_erp\cust_az12.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Tiempo de carga: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> truncate en tabla bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Insertando datos en: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Andres\Documents\Analisis de datos\SQL\data-warehouse-sql\datasets\source_erp\loc_a101.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Tiempo de carga: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> truncate en tabla bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Insertando datos en: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Andres\Documents\Analisis de datos\SQL\data-warehouse-sql\datasets\source_erp\px_cat_g1v2.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Tiempo de carga: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------------';
		SET @end_time_layer = GETDATE();
		PRINT 'Carga de la capa bronze completa'
		PRINT '>> Tiempo de carga de la capa bronze: ' + CAST (DATEDIFF(second, @start_time_layer, @end_time_layer) AS NVARCHAR) + ' segundos';
	END TRY
	BEGIN CATCH
		PRINT '===================================================';
		PRINT 'OCURRIO UN ERROR DURANTE LA CARGA DE LA CAPA BRONZE';
		PRINT 'ERROR: ' + ERROR_MESSAGE();
		PRINT 'ERROR: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR: ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '===================================================';
	END CATCH
END