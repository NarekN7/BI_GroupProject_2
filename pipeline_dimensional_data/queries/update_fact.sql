DECLARE @DatabaseName NVARCHAR(128) = 'ORDER_DDS';
DECLARE @SchemaName NVARCHAR(128) = 'dbo';
DECLARE @FactTableName NVARCHAR(128) = 'FactOrders';
DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate DATE = '2024-12-31';

DECLARE @SQL NVARCHAR(MAX);

SET @SQL = '
SET IDENTITY_INSERT [' + @DatabaseName + '].[' + @SchemaName + '].[' + @FactTableName + '] ON;

MERGE INTO [' + @DatabaseName + '].[' + @SchemaName + '].[' + @FactTableName + '] AS fact
USING (
    SELECT
        src.staging_raw_id,
        sor.SurrogateKey AS OrderSK,
        src.OrderID,
        dimCustomer.CustomerSK,
        dimEmployee.EmployeeSK,
        src.OrderDate,
        src.RequiredDate,
        src.ShippedDate,
        dimShipper.ShipperSK,
        src.Freight,
        src.ShipName,
        src.ShipAddress,
        src.ShipCity,
        src.ShipRegion,
        src.ShipPostalCode,
        src.ShipCountry,
        dimTerritory.TerritorySK
    FROM [' + @DatabaseName + '].[' + @SchemaName + '].[staging_raw_Orders] AS src
    LEFT JOIN [' + @DatabaseName + '].[' + @SchemaName + '].[Dim_SOR] AS sor
        ON sor.TableName = ''Orders'' AND sor.SurrogateKey = src.staging_raw_id
    LEFT JOIN [' + @DatabaseName + '].[' + @SchemaName + '].[DimCustomers] AS dimCustomer
        ON dimCustomer.CustomerID = src.CustomerID
    LEFT JOIN [' + @DatabaseName + '].[' + @SchemaName + '].[DimEmployees] AS dimEmployee
        ON dimEmployee.EmployeeID = src.EmployeeID
    LEFT JOIN [' + @DatabaseName + '].[' + @SchemaName + '].[DimShippers] AS dimShipper
        ON dimShipper.ShipperID = src.ShipVia
    LEFT JOIN [' + @DatabaseName + '].[' + @SchemaName + '].[DimTerritories] AS dimTerritory
        ON dimTerritory.TerritoryID = src.TerritoryID
    WHERE src.OrderDate BETWEEN @StartDate AND @EndDate
) AS staging
ON fact.OrderSK = staging.OrderSK

WHEN MATCHED THEN
    UPDATE SET
        fact.OrderID = staging.OrderID,
        fact.CustomerSK = staging.CustomerSK,
        fact.EmployeeSK = staging.EmployeeSK,
        fact.OrderDate = staging.OrderDate,
        fact.RequiredDate = staging.RequiredDate,
        fact.ShippedDate = staging.ShippedDate,
        fact.ShipperSK = staging.ShipperSK,
        fact.Freight = staging.Freight,
        fact.ShipName = staging.ShipName,
        fact.ShipAddress = staging.ShipAddress,
        fact.ShipCity = staging.ShipCity,
        fact.ShipRegion = staging.ShipRegion,
        fact.ShipPostalCode = staging.ShipPostalCode,
        fact.ShipCountry = staging.ShipCountry,
        fact.TerritorySK = staging.TerritorySK

WHEN NOT MATCHED THEN
    INSERT (OrderSK, OrderID, CustomerSK, EmployeeSK, OrderDate, RequiredDate, ShippedDate, ShipperSK, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, TerritorySK)
    VALUES (staging.OrderSK, staging.OrderID, staging.CustomerSK, staging.EmployeeSK, staging.OrderDate, staging.RequiredDate, staging.ShippedDate, staging.ShipperSK, staging.Freight, staging.ShipName, staging.ShipAddress, staging.ShipCity, staging.ShipRegion, staging.ShipPostalCode, staging.ShipCountry, staging.TerritorySK);

SET IDENTITY_INSERT [' + @DatabaseName + '].[' + @SchemaName + '].[' + @FactTableName + '] OFF;
';

EXEC sp_executesql @SQL, 
    N'@StartDate DATE, @EndDate DATE', 
    @StartDate = @StartDate, 
    @EndDate = @EndDate;
