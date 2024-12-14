SET IDENTITY_INSERT DimCustomers ON;

MERGE INTO DimCustomers AS dim
USING (
    SELECT
        src.staging_raw_id,
        ISNULL(sor.SurrogateKey, src.staging_raw_id) AS CustomerSK, -- Use `staging_raw_id` if `SurrogateKey` is NULL
        src.CustomerID,
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
        GETDATE() AS StartDate,
        NULL AS EndDate,
        1 AS IsCurrent
    FROM staging_raw_Customers AS src
    LEFT JOIN Dim_SOR AS sor
        ON sor.TableName = 'Customers' AND sor.SurrogateKey = src.staging_raw_id
) AS staging
ON dim.CustomerSK = staging.CustomerSK

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
        dim.EndDate = NULL,
        dim.IsCurrent = 1

WHEN NOT MATCHED THEN
    INSERT (CustomerSK, CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax, StartDate, EndDate, IsCurrent)
    VALUES (staging.CustomerSK, staging.CustomerID, staging.CompanyName, staging.ContactName, staging.ContactTitle, staging.Address, staging.City, staging.Region, staging.PostalCode, staging.Country, staging.Phone, staging.Fax, staging.StartDate, staging.EndDate, staging.IsCurrent);

SET IDENTITY_INSERT DimCustomers OFF;

