SET IDENTITY_INSERT FactOrders ON;

MERGE INTO FactOrders AS fact
USING (
    SELECT
        src.staging_raw_id,
        sor.SurrogateKey AS OrderSK,
        src.OrderID,
        src.CustomerID,
        src.EmployeeID,
        src.OrderDate,
        src.RequiredDate,
        src.ShippedDate,
        src.ShipVia,
        src.Freight,
        src.ShipName,
        src.ShipAddress,
        src.ShipCity,
        src.ShipRegion,
        src.ShipPostalCode,
        src.ShipCountry,
        src.TerritoryID
    FROM staging_raw_Orders AS src
    LEFT JOIN Dim_SOR AS sor
        ON sor.TableName = 'Orders' AND sor.SurrogateKey = src.staging_raw_id
) AS staging
ON fact.OrderSK = staging.OrderSK

WHEN MATCHED THEN
    UPDATE SET
        fact.OrderID = staging.OrderID,
        fact.CustomerSK = staging.CustomerID,
        fact.EmployeeSK = staging.EmployeeID,
        fact.OrderDate = staging.OrderDate,
        fact.RequiredDate = staging.RequiredDate,
        fact.ShippedDate = staging.ShippedDate,
        fact.ShipperSK = staging.ShipVia,
        fact.Freight = staging.Freight,
        fact.ShipName = staging.ShipName,
        fact.ShipAddress = staging.ShipAddress,
        fact.ShipCity = staging.ShipCity,
        fact.ShipRegion = staging.ShipRegion,
        fact.ShipPostalCode = staging.ShipPostalCode,
        fact.ShipCountry = staging.ShipCountry,
        fact.TerritorySK = staging.TerritoryID

WHEN NOT MATCHED THEN
    INSERT (OrderSK, OrderID, CustomerSK, EmployeeSK, OrderDate, RequiredDate, ShippedDate, ShipperSK, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, TerritorySK)
    VALUES (staging.OrderSK, staging.OrderID, staging.CustomerID, staging.EmployeeID, staging.OrderDate, staging.RequiredDate, staging.ShippedDate, staging.ShipVia, staging.Freight, staging.ShipName, staging.ShipAddress, staging.ShipCity, staging.ShipRegion, staging.ShipPostalCode, staging.ShipCountry, staging.TerritoryID);

	SET IDENTITY_INSERT FactOrders OFF;