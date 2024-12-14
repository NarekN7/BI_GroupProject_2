SET IDENTITY_INSERT DimShippers ON;

WITH FilteredStaging AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY staging_raw_id ORDER BY staging_raw_id) AS RowNum
    FROM staging_raw_Shippers
)
MERGE INTO DimShippers AS dim
USING (
    SELECT
        src.staging_raw_id,
        ISNULL(sor.SurrogateKey, src.staging_raw_id) AS ShipperSK, 
        src.ShipperID,
        src.CompanyName,
        src.Phone,
        0 AS IsDeleted
    FROM FilteredStaging AS src
    LEFT JOIN Dim_SOR AS sor
        ON sor.TableName = 'Shippers' AND sor.SurrogateKey = src.staging_raw_id
    WHERE RowNum = 1 
) AS staging
ON dim.ShipperSK = staging.ShipperSK

WHEN MATCHED THEN
    UPDATE SET
        dim.CompanyName = staging.CompanyName,
        dim.Phone = staging.Phone,
        dim.IsDeleted = staging.IsDeleted

WHEN NOT MATCHED THEN
    INSERT (ShipperSK, ShipperID, CompanyName, Phone, IsDeleted)
    VALUES (staging.ShipperSK, staging.ShipperID, staging.CompanyName, staging.Phone, staging.IsDeleted);

SET IDENTITY_INSERT DimShippers OFF;
