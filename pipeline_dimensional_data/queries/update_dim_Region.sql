SET IDENTITY_INSERT DimRegion ON;

WITH FilteredStaging AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY staging_raw_id ORDER BY staging_raw_id) AS RowNum
    FROM staging_raw_Region
)
MERGE INTO DimRegion AS dim
USING (
    SELECT
        src.staging_raw_id,
        ISNULL(sor.SurrogateKey, src.staging_raw_id) AS RegionSK,
        src.RegionID,
        src.RegionDescription,
        src.RegionCategory,
        src.RegionImportance,
        GETDATE() AS StartDate,
        NULL AS EndDate
    FROM FilteredStaging AS src
    LEFT JOIN Dim_SOR AS sor
        ON sor.TableName = 'Region' AND sor.SurrogateKey = src.staging_raw_id
    WHERE RowNum = 1 
) AS staging
ON dim.RegionSK = staging.RegionSK

WHEN MATCHED THEN
    UPDATE SET
        dim.RegionDescription = staging.RegionDescription,
        dim.RegionCategory = staging.RegionCategory,
        dim.RegionImportance = staging.RegionImportance,
        dim.EndDate = NULL

WHEN NOT MATCHED THEN
    INSERT (RegionSK, RegionID, RegionDescription, RegionCategory, RegionImportance, StartDate, EndDate)
    VALUES (staging.RegionSK, staging.RegionID, staging.RegionDescription, staging.RegionCategory, staging.RegionImportance, staging.StartDate, staging.EndDate);

SET IDENTITY_INSERT DimRegion OFF;
