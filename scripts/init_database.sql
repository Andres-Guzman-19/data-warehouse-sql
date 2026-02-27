/*
CREAR BASE DE DATOS
-----------------------------------------------------

PROPOSITO:
	El sript crea una base de datos llamada DataWarehouse, en caso de que exista esta base la elimina y vuelve a crear
	Ademas, se crean tres esquemas en la base de datos:
		- bronze
		- silver
		- gold
ADVERTENCIA:
	Al ejecutar el script se elimina de forma permanente la base de datos y por lo tanto todos los datos que contengan
*/

USE master;

-- Eliminar y recrear la base de datos 'DataWarehouse'

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse
END;
GO

--Crear Base datos
CREATE DATABASE DataWarehouse;
GO


USE DataWarehouse;
GO

--Crear Esquemas

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO