SET IDENTITY_INSERT DimSuppliers ON;

WITH FilteredStaging AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY staging_raw_id ORDER BY staging_raw_id) AS RowNum
    FROM staging_raw_Suppliers
)
MERGE INTO DimSuppliers AS dim
USING (
    SELECT
        src.staging_raw_id,
        ISNULL(sor.SurrogateKey, src.staging_raw_id) AS SupplierSK, 
        src.SupplierID,
        src.CompanyName,
        src.ContactName,
        src.ContactTitle,
        src.Address,
        src.City,
        src.Region,
        src.PostalCode,
        src.Country,
        src.Phone,
        src.Fax,
        src.HomePage,
        NULL AS CurrentContactName,
        NULL AS PreviousContactName
    FROM FilteredStaging AS src
    LEFT JOIN Dim_SOR AS sor
        ON sor.TableName = 'Suppliers' AND sor.SurrogateKey = src.staging_raw_id
    WHERE RowNum = 1 
) AS staging
ON dim.SupplierSK = staging.SupplierSK

WHEN MATCHED THEN
    UPDATE SET
        dim.CompanyName = staging.CompanyName,
        dim.ContactName = staging.ContactName,
        dim.ContactTitle = staging.ContactTitle,
        dim.Address = staging.Address,
        dim.City = staging.City,
        dim.Region = staging.Region,
        dim.PostalCode = staging.PostalCode,
        dim.Country = staging.Country,
        dim.Phone = staging.Phone,
        dim.Fax = staging.Fax,
        dim.HomePage = staging.HomePage,
        dim.CurrentContactName = staging.CurrentContactName,
        dim.PreviousContactName = staging.PreviousContactName

WHEN NOT MATCHED THEN
    INSERT (SupplierSK, SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax, HomePage, CurrentContactName, PreviousContactName)
    VALUES (staging.SupplierSK, staging.SupplierID, staging.CompanyName, staging.ContactName, staging.ContactTitle, staging.Address, staging.City, staging.Region, staging.PostalCode, staging.Country, staging.Phone, staging.Fax, staging.HomePage, staging.CurrentContactName, staging.PreviousContactName);

SET IDENTITY_INSERT DimSuppliers OFF;
