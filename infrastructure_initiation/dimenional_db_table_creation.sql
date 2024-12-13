DROP TABLE IF EXISTS DimCategories;
DROP TABLE IF EXISTS DimCustomers;
DROP TABLE IF EXISTS DimEmployees;
DROP TABLE IF EXISTS DimProducts;
DROP TABLE IF EXISTS DimRegion;
DROP TABLE IF EXISTS DimShippers;
DROP TABLE IF EXISTS DimSuppliers;
DROP TABLE IF EXISTS DimTerritories;
DROP TABLE IF EXISTS FactOrders;
DROP TABLE IF EXISTS Dim_SOR;

CREATE TABLE DimCategories (
    CategorySK INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    CategoryName NVARCHAR(50) NOT NULL, 
    Description NVARCHAR(255)
);

CREATE TABLE DimCustomers (
    CustomerSK INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(5) NOT NULL,
    CompanyName NVARCHAR(255) NOT NULL,
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(100),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(100),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50),
    StartDate DATE NOT NULL,
    EndDate DATE,
    IsCurrent BIT NOT NULL
);

CREATE TABLE DimEmployees (
    EmployeeSK INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    LastName NVARCHAR(255) NOT NULL,
    FirstName NVARCHAR(255) NOT NULL,
    Title NVARCHAR(255),
    TitleOfCourtesy NVARCHAR(50),
    BirthDate DATE,
    HireDate DATE,
    Address NVARCHAR(255),
    City NVARCHAR(100),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(100),
    HomePhone NVARCHAR(50),
    Extension NVARCHAR(10),
    Notes NVARCHAR(MAX),
    ReportsTo INT,
    PhotoPath NVARCHAR(255),
    IsDeleted BIT NOT NULL
);

CREATE TABLE DimProducts (
    ProductSK INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ProductName NVARCHAR(255) NOT NULL,
    SupplierID INT NOT NULL,
    CategoryID INT NOT NULL,
    QuantityPerUnit NVARCHAR(255),
    UnitPrice DECIMAL(10, 2),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued BIT
);

CREATE TABLE DimRegion (
    RegionSK INT IDENTITY(1,1) PRIMARY KEY,
    RegionID INT NOT NULL,
    RegionDescription NVARCHAR(255) NOT NULL,
    RegionCategory NVARCHAR(50),
    RegionImportance NVARCHAR(50),
    StartDate DATE NOT NULL,
    EndDate DATE
);

CREATE TABLE DimShippers (
    ShipperSK INT IDENTITY(1,1) PRIMARY KEY,
    ShipperID INT NOT NULL,
    CompanyName NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(50),
    IsDeleted BIT NOT NULL
);

CREATE TABLE DimSuppliers (
    SupplierSK INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL,
    CompanyName NVARCHAR(255) NOT NULL,
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(100),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(100),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50),
    HomePage NVARCHAR(MAX),
    CurrentContactName NVARCHAR(255),
    PreviousContactName NVARCHAR(255)
);

CREATE TABLE DimTerritories (
    TerritorySK INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID NVARCHAR(20) NOT NULL,
    TerritoryDescription NVARCHAR(255) NOT NULL,
    TerritoryCode NVARCHAR(2),
    RegionID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE
);

CREATE TABLE FactOrders (
    OrderSK INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    CustomerSK INT NOT NULL,
    EmployeeSK INT NOT NULL,
    OrderDate DATE,
    RequiredDate DATE,
    ShippedDate DATE,
    ShipperSK INT NOT NULL,
    Freight DECIMAL(10, 2),
    ShipName NVARCHAR(255),
    ShipAddress NVARCHAR(255),
    ShipCity NVARCHAR(100),
    ShipRegion NVARCHAR(50),
    ShipPostalCode NVARCHAR(20),
    ShipCountry NVARCHAR(100),
    TerritorySK INT NOT NULL,
    CONSTRAINT FK_FactOrders_Customer FOREIGN KEY (CustomerSK) REFERENCES DimCustomers(CustomerSK),
    CONSTRAINT FK_FactOrders_Employee FOREIGN KEY (EmployeeSK) REFERENCES DimEmployees(EmployeeSK),
    CONSTRAINT FK_FactOrders_Shipper FOREIGN KEY (ShipperSK) REFERENCES DimShippers(ShipperSK),
    CONSTRAINT FK_FactOrders_Territory FOREIGN KEY (TerritorySK) REFERENCES DimTerritories(TerritorySK)
);

CREATE TABLE Dim_SOR (
    TableName NVARCHAR(100) PRIMARY KEY,
    SurrogateKey INT NOT NULL
);