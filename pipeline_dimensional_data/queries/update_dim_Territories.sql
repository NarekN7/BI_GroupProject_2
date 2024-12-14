SET IDENTITY_INSERT DimTerritories ON;

WITH FilteredStaging AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY staging_raw_id ORDER BY staging_raw_id) AS RowNum
    FROM staging_raw_Territories
)
MERGE INTO DimTerritories AS dim
USING (
    SELECT
        src.staging_raw_id,
        ISNULL(sor.SurrogateKey, src.staging_raw_id) AS TerritorySK, 
        src.TerritoryID,
        src.TerritoryDescription,
        src.TerritoryCode,
        src.RegionID,
        GETDATE() AS StartDate,
        NULL AS EndDate
    FROM FilteredStaging AS src
    LEFT JOIN Dim_SOR AS sor
        ON sor.TableName = 'Territories' AND sor.SurrogateKey = src.staging_raw_id
    WHERE RowNum = 1 
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
