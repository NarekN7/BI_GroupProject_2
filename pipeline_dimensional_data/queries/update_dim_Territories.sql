SET IDENTITY_INSERT DimTerritories ON;

MERGE INTO DimTerritories AS dim
USING (
    SELECT
        src.staging_raw_id,
        sor.SurrogateKey AS TerritorySK,
        src.TerritoryID,
        src.TerritoryDescription,
        src.TerritoryCode,
        src.RegionID,
        GETDATE() AS StartDate,
        NULL AS EndDate
    FROM staging_raw_Territories AS src
    LEFT JOIN Dim_SOR AS sor
        ON sor.TableName = 'Territories' AND sor.SurrogateKey = src.staging_raw_id
) AS staging
ON dim.TerritorySK = staging.TerritorySK

WHEN MATCHED THEN
    UPDATE SET
        dim.TerritoryDescription = staging.TerritoryDescription,
        dim.TerritoryCode = staging.TerritoryCode,
        dim.RegionID = staging.RegionID,
        dim.EndDate = NULL

WHEN NOT MATCHED THEN
    INSERT (TerritorySK, TerritoryID, TerritoryDescription, TerritoryCode, RegionID, StartDate, EndDate)
    VALUES (staging.TerritorySK, staging.TerritoryID, staging.TerritoryDescription, staging.TerritoryCode, staging.RegionID, staging.StartDate, staging.EndDate);

SET IDENTITY_INSERT DimTerritories OFF;