SET IDENTITY_INSERT DimShippers ON;

MERGE INTO DimShippers AS dim
USING (
    SELECT
        src.staging_raw_id,
        sor.SurrogateKey AS ShipperSK,
        src.ShipperID,
        src.CompanyName,
        src.Phone,
        0 AS IsDeleted
    FROM staging_raw_Shippers AS src
    LEFT JOIN Dim_SOR AS sor
        ON sor.TableName = 'Shippers' AND sor.SurrogateKey = src.staging_raw_id
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