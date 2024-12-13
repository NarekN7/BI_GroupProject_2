SET IDENTITY_INSERT DimCategories ON;

MERGE INTO DimCategories AS dim
USING (
    SELECT
        src.staging_raw_id,
        sor.SurrogateKey AS CategorySK,
        src.CategoryID,
        src.CategoryName,
        src.Description
    FROM staging_raw_Categories AS src
    LEFT JOIN Dim_SOR AS sor
        ON sor.TableName = 'Categories' AND sor.SurrogateKey = src.staging_raw_id
) AS staging
ON dim.CategorySK = staging.CategorySK

WHEN MATCHED THEN
    UPDATE SET
        dim.CategoryName = staging.CategoryName,
        dim.Description = staging.Description

WHEN NOT MATCHED THEN
    INSERT (CategorySK, CategoryID, CategoryName, Description)
    VALUES (staging.CategorySK, staging.CategoryID, staging.CategoryName, staging.Description);

SET IDENTITY_INSERT DimCategories OFF;
