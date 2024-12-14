-- Parameters
DECLARE @database_name NVARCHAR(50) = 'ORDER_DDS';
DECLARE @schema_name NVARCHAR(50) = 'dbo';
DECLARE @table_name NVARCHAR(50) = 'FactOrders';
DECLARE @start_date DATE = '2024-01-01';
DECLARE @end_date DATE = '2024-12-31';

-- Dynamic SQL query
DECLARE @sql NVARCHAR(MAX);

SET @sql = '
INSERT INTO [' + @database_name + '].[' + @schema_name + '].[' + @table_name + '] (
    OrderID,
    CustomerSK,
    EmployeeSK,
    ProductSK,
    OrderDate,
    ShippedDate,
    ShipperSK,
    Quantity,
    UnitPrice,
    Discount
)
SELECT
    so.OrderID,
    dc.CustomerSK,
    de.EmployeeSK,
    dp.ProductSK,
    so.OrderDate,
    so.ShippedDate,
    ds.ShipperSK,
    od.Quantity,
    od.UnitPrice,
    od.Discount
FROM
    [' + @database_name + '].[' + @schema_name + '].[staging_raw_Orders] so
LEFT JOIN [' + @database_name + '].[' + @schema_name + '].[staging_raw_OrderDetails] od
    ON so.OrderID = od.OrderID
LEFT JOIN [' + @database_name + '].[' + @schema_name + '].[DimCustomers] dc
    ON so.CustomerID = dc.CustomerID
LEFT JOIN [' + @database_name + '].[' + @schema_name + '].[DimEmployees] de
    ON so.EmployeeID = de.EmployeeID
LEFT JOIN [' + @database_name + '].[' + @schema_name + '].[DimProducts] dp
    ON od.ProductID = dp.ProductID
LEFT JOIN [' + @database_name + '].[' + @schema_name + '].[DimRegion] dr
    ON so.TerritoryID = dr.RegionID
LEFT JOIN [' + @database_name + '].[' + @schema_name + '].[DimShippers] ds
    ON so.ShipVia = ds.ShipperID
WHERE
    so.OrderDate BETWEEN @start_date AND @end_date
    AND dc.CustomerSK IS NOT NULL
    AND de.EmployeeSK IS NOT NULL
    AND dp.ProductSK IS NOT NULL
    AND dr.RegionSK IS NOT NULL
    AND ds.ShipperSK IS NOT NULL;
';

-- Execute the dynamic SQL
EXEC sp_executesql @sql, N'@start_date DATE, @end_date DATE', @start_date, @end_date;