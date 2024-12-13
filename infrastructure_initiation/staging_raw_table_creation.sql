DROP TABLE IF EXISTS staging_raw_Categories;
DROP TABLE IF EXISTS staging_raw_Customers;
DROP TABLE IF EXISTS staging_raw_Employees;
DROP TABLE IF EXISTS staging_raw_OrderDetails;
DROP TABLE IF EXISTS staging_raw_Orders;
DROP TABLE IF EXISTS staging_raw_Products;
DROP TABLE IF EXISTS staging_raw_Region;
DROP TABLE IF EXISTS staging_raw_Shippers;
DROP TABLE IF EXISTS staging_raw_Suppliers;
DROP TABLE IF EXISTS staging_raw_Territories;


CREATE TABLE staging_raw_Region (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    RegionID INT NOT NULL UNIQUE,
    RegionDescription NVARCHAR(255) NOT NULL,
    RegionCategory NVARCHAR(50),
    RegionImportance NVARCHAR(50)
);


CREATE TABLE staging_raw_Shippers (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    ShipperID INT NOT NULL UNIQUE,
    CompanyName NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(50)
);


CREATE TABLE staging_raw_Suppliers (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL UNIQUE,
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
    HomePage NVARCHAR(MAX)
);


CREATE TABLE staging_raw_Categories (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL UNIQUE,
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255)
);


CREATE TABLE staging_raw_Territories (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID NVARCHAR(20) NOT NULL UNIQUE,
    TerritoryDescription NVARCHAR(255) NOT NULL,
    TerritoryCode NVARCHAR(2),
    RegionID INT NOT NULL, 
    CONSTRAINT FK_Territories_RegionID FOREIGN KEY (RegionID) REFERENCES staging_raw_Region(RegionID)
);


CREATE TABLE staging_raw_Customers (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(5) NOT NULL UNIQUE,
    CompanyName NVARCHAR(255) NOT NULL,
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(100),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(100),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50)
);


CREATE TABLE staging_raw_Employees (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL UNIQUE,
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
    ReportsTo INT, -- Foreign key added below
    PhotoPath NVARCHAR(255),
    CONSTRAINT FK_Employees_ReportsTo FOREIGN KEY (ReportsTo) REFERENCES staging_raw_Employees(EmployeeID)
);


CREATE TABLE staging_raw_Orders (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE,
    CustomerID NVARCHAR(5) NOT NULL,
    EmployeeID INT NOT NULL,
    OrderDate DATE,
    RequiredDate DATE,
    ShippedDate DATE,
    ShipVia INT NOT NULL, 
    Freight DECIMAL(10, 2),
    ShipName NVARCHAR(255),
    ShipAddress NVARCHAR(255),
    ShipCity NVARCHAR(100),
    ShipRegion NVARCHAR(50),
    ShipPostalCode NVARCHAR(20),
    ShipCountry NVARCHAR(100),
    TerritoryID NVARCHAR(20) NOT NULL, 
    CONSTRAINT FK_Orders_CustomerID FOREIGN KEY (CustomerID) REFERENCES staging_raw_Customers(CustomerID),
    CONSTRAINT FK_Orders_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES staging_raw_Employees(EmployeeID),
    CONSTRAINT FK_Orders_ShipVia FOREIGN KEY (ShipVia) REFERENCES staging_raw_Shippers(ShipperID),
    CONSTRAINT FK_Orders_TerritoryID FOREIGN KEY (TerritoryID) REFERENCES staging_raw_Territories(TerritoryID)
);


CREATE TABLE staging_raw_Products (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL UNIQUE,
    ProductName NVARCHAR(255) NOT NULL,
    SupplierID INT NOT NULL,
    CategoryID INT NOT NULL,
    QuantityPerUnit NVARCHAR(255),
    UnitPrice DECIMAL(10, 2),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued BIT,
    CONSTRAINT FK_Products_CategoryID FOREIGN KEY (CategoryID) REFERENCES staging_raw_Categories(CategoryID),
    CONSTRAINT FK_Products_SupplierID FOREIGN KEY (SupplierID) REFERENCES staging_raw_Suppliers(SupplierID)
);


CREATE TABLE staging_raw_OrderDetails (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL, 
    ProductID INT NOT NULL, 
    UnitPrice DECIMAL(10, 2),
    Quantity INT,
    Discount DECIMAL(4, 2),
    CONSTRAINT FK_OrderDetails_OrderID FOREIGN KEY (OrderID) REFERENCES staging_raw_Orders(OrderID),
    CONSTRAINT FK_OrderDetails_ProductID FOREIGN KEY (ProductID) REFERENCES staging_raw_Products(ProductID)
);
