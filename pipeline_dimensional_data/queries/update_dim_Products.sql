SET IDENTITY_INSERT DimProducts ON;

WITH FilteredStaging AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY staging_raw_id ORDER BY staging_raw_id) AS RowNum
    FROM staging_raw_Products
)
MERGE INTO DimProducts AS dim
USING (
    SELECT
        src.staging_raw_id,
        ISNULL(sor.SurrogateKey, src.staging_raw_id) AS ProductSK, 
        src.ProductID,
        src.ProductName,
        src.SupplierID,
        src.CategoryID,
        src.QuantityPerUnit,
        src.UnitPrice,
        src.UnitsInStock,
        src.UnitsOnOrder,
        src.ReorderLevel,
        src.Discontinued
    FROM FilteredStaging AS src
    LEFT JOIN Dim_SOR AS sor
        ON sor.TableName = 'Products' AND sor.SurrogateKey = src.staging_raw_id
    WHERE RowNum = 1 
) AS staging
ON dim.ProductSK = staging.ProductSK

WHEN MATCHED THEN
    UPDATE SET
        dim.ProductName = staging.ProductName,
        dim.SupplierID = staging.SupplierID,
        dim.CategoryID = staging.CategoryID,
        dim.QuantityPerUnit = staging.QuantityPerUnit,
        dim.UnitPrice = staging.UnitPrice,
        dim.UnitsInStock = staging.UnitsInStock,
        dim.UnitsOnOrder = staging.UnitsOnOrder,
        dim.ReorderLevel = staging.ReorderLevel,
        dim.Discontinued = staging.Discontinued

WHEN NOT MATCHED THEN
    INSERT (ProductSK, ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
    VALUES (staging.ProductSK, staging.ProductID, staging.ProductName, staging.SupplierID, staging.CategoryID, staging.QuantityPerUnit, staging.UnitPrice, staging.UnitsInStock, staging.UnitsOnOrder, staging.ReorderLevel, staging.Discontinued);

SET IDENTITY_INSERT DimProducts OFF;
