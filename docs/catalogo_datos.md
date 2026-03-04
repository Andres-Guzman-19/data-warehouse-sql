# 📘 Catálogo de Datos  
**Capa:** Gold  
**Modelo:** Esquema en estrella (Star Schema)

---

## 🎯 Propósito General

Este modelo de datos soporta el análisis de ventas permitiendo evaluar el desempeño comercial por cliente, producto y fechas del proceso de venta.

La tabla `fact_sales` almacena métricas transaccionales, mientras que `dim_customers` y `dim_products` proporcionan contexto descriptivo.

---

# 🧾 Tabla: gold.fact_sales

## 📌 Propósito
Almacena las transacciones de ventas a nivel de pedido, incluyendo métricas como monto vendido, cantidad y precio, junto con claves foráneas hacia dimensiones de clientes y productos.

## 🔑 Tipo
Tabla de Hechos (Fact Table)

| Columna        | Tipo de Dato      | Propósito |
|---------------|------------------|------------|
| order_number  | NVARCHAR(50)       | Identificador único del pedido |
| product_key   | INT               | Clave foránea que referencia dim_products.product_key |
| customer_key  | INT               | Clave foránea que referencia dim_customers.customer_key |
| order_date    | DATE              | Fecha en que se realizó el pedido |
| shipping_date | DATE              | Fecha en que se envió el pedido |
| due_date      | DATE              | Fecha límite de entrega del pedido |
| sales_amount  | INT     | Monto total de la venta |
| quantity      | INT               | Cantidad de productos vendidos |
| price         | INT     | Precio unitario del producto al momento de la venta |

---

# 👥 Tabla: gold.dim_customers

## 📌 Propósito
Contiene la información descriptiva de los clientes para segmentación y análisis demográfico.

## 🔑 Tipo
Tabla de Dimensión (Dimension Table)

| Columna         | Tipo de Dato      | Propósito |
|----------------|------------------|------------|
| customer_key   | INT (PK)          | Clave sustituta primaria del cliente |
| customer_id    | INT               | Identificador natural del cliente en el sistema origen |
| customer_number| NVARCHAR(50)       | Código o número de cliente |
| first_name     | NVARCHAR(50)      | Nombre del cliente |
| last_name      | NVARCHAR(50)      | Apellido del cliente |
| marital_status | NVARCHAR(50)       | Estado civil del cliente |
| country        | NVARCHAR(50)      | País de residencia |
| gender         | NVARCHAR(50)       | Género del cliente |
| birthday       | DATE              | Fecha de nacimiento |
| create_date    | DATE              | Fecha de creación del cliente en el sistema |

---

# 📦 Tabla: gold.dim_products

## 📌 Propósito
Contiene la información descriptiva de los productos para análisis por categoría, línea y rentabilidad.

## 🔑 Tipo
Tabla de Dimensión (Dimension Table)

| Columna        | Tipo de Dato      | Propósito |
|---------------|------------------|------------|
| product_key   | INT (PK)          | Clave sustituta primaria del producto |
| product_id    | INT               | Identificador natural del producto en el sistema origen |
| product_number| NVARCHAR(50)       | Código del producto |
| product_name  | NVARCHAR(50)      | Nombre descriptivo del producto |
| category_id   | NVARCHAR(50)               | Identificador de la categoría |
| category      | NVARCHAR(50)      | Categoría principal del producto |
| subcategory   | NVARCHAR(50)      | Subcategoría del producto |
| maintance     | NVARCHAR(50)       | Indicador o tipo de mantenimiento asociado |
| cost          | INT     | Costo base del producto |
| product_line  | NVARCHAR(50)       | Línea de producto |
| start_date    | DATE              | Fecha desde la cual el producto está disponible |

---

# 🔗 Relaciones

- fact_sales.customer_key → dim_customers.customer_key  
- fact_sales.product_key → dim_products.product_key  

Relaciones:
- 1 Cliente → N Ventas  
- 1 Producto → N Ventas  

---
