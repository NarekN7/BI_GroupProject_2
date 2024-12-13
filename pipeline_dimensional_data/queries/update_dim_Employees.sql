SET IDENTITY_INSERT DimEmployees ON;

MERGE INTO DimEmployees AS dim
USING (
    SELECT
        src.staging_raw_id,
        sor.SurrogateKey AS EmployeeSK,
        src.EmployeeID,
        src.LastName,
        src.FirstName,
        src.Title,
        src.TitleOfCourtesy,
        src.BirthDate,
        src.HireDate,
        src.Address,
        src.City,
        src.Region,
        src.PostalCode,
        src.Country,
        src.HomePhone,
        src.Extension,
        src.Notes,
        src.ReportsTo,
        src.PhotoPath,
        0 AS IsDeleted    FROM staging_raw_Employees AS src
    LEFT JOIN Dim_SOR AS sor
        ON sor.TableName = 'Employees' AND sor.SurrogateKey = src.staging_raw_id
) AS staging
ON dim.EmployeeSK = staging.EmployeeSK

WHEN MATCHED THEN
    UPDATE SET
        dim.LastName = staging.LastName,
        dim.FirstName = staging.FirstName,
        dim.Title = staging.Title,
        dim.TitleOfCourtesy = staging.TitleOfCourtesy,
        dim.BirthDate = staging.BirthDate,
        dim.HireDate = staging.HireDate,
        dim.Address = staging.Address,
        dim.City = staging.City,
        dim.Region = staging.Region,
        dim.PostalCode = staging.PostalCode,
        dim.Country = staging.Country,
        dim.HomePhone = staging.HomePhone,
        dim.Extension = staging.Extension,
        dim.Notes = staging.Notes,
        dim.ReportsTo = staging.ReportsTo,
        dim.PhotoPath = staging.PhotoPath,
        dim.IsDeleted = staging.IsDeleted

WHEN NOT MATCHED THEN
    INSERT (EmployeeSK, EmployeeID, LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, Address, City, Region, PostalCode, Country, HomePhone, Extension, Notes, ReportsTo, PhotoPath, IsDeleted)
    VALUES (staging.EmployeeSK, staging.EmployeeID, staging.LastName, staging.FirstName, staging.Title, staging.TitleOfCourtesy, staging.BirthDate, staging.HireDate, staging.Address, staging.City, staging.Region, staging.PostalCode, staging.Country, staging.HomePhone, staging.Extension, staging.Notes, staging.ReportsTo, staging.PhotoPath, staging.IsDeleted);

SET IDENTITY_INSERT DimEmployees OFF;