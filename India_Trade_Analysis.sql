DROP DATABASE IF EXISTS India_Trade_Analysis;
CREATE DATABASE India_Trade_Analysis;
USE India_Trade_Analysis;
SELECT DATABASE();
SHOW TABLES;
RENAME TABLE `india_import_export_final_raw_dataset_25000 (1)`
TO Raw_Trade_Data;
SHOW TABLES;
SELECT COUNT(*) AS Total_Rows
FROM Raw_Trade_Data;
SELECT *
FROM Raw_Trade_Data
LIMIT 5;
SHOW COLUMNS FROM Raw_Trade_Data;
ALTER TABLE Raw_Trade_Data
CHANGE COLUMN `ï»¿Transaction_ID` Transaction_ID INT;
SET SQL_SAFE_UPDATES = 0;
UPDATE Raw_Trade_Data
SET Trade_Date = STR_TO_DATE(Trade_Date, '%d-%m-%Y');
ALTER TABLE Raw_Trade_Data
MODIFY COLUMN Trade_Date DATE;
SET SQL_SAFE_UPDATES = 1;
DESCRIBE Raw_Trade_Data;
CREATE TABLE Countries
(
    Country_ID INT AUTO_INCREMENT PRIMARY KEY,
    Country_Name VARCHAR(100),
    Region VARCHAR(100),
    Continent VARCHAR(100)
);
INSERT INTO Countries
(
    Country_Name,
    Region,
    Continent
)
SELECT DISTINCT
    Country,
    Region,
    Continent
FROM Raw_Trade_Data;
SELECT *
FROM Countries
LIMIT 10;
SELECT *
FROM Countries
LIMIT 10;

CREATE TABLE Products
(
    Product_ID INT AUTO_INCREMENT PRIMARY KEY,
    Product_Name VARCHAR(100),
    Product_Category VARCHAR(100),
    HS_Code INT,
    Unit VARCHAR(20)
);

INSERT INTO Products
(
    Product_Name,
    Product_Category,
    HS_Code,
    Unit
)

SELECT DISTINCT
    Product,
    Product_Category,
    HS_Code,
    Unit
FROM Raw_Trade_Data;
SELECT *
FROM Products
LIMIT 10;
SELECT COUNT(*) AS Total_Products
FROM Products;

CREATE TABLE Companies
(
    Company_ID INT AUTO_INCREMENT PRIMARY KEY,
    Company_Name VARCHAR(100),
    Industry VARCHAR(100),
    Company_Type VARCHAR(50),
    Headquarters VARCHAR(100)
);
INSERT INTO Companies
(
    Company_Name,
    Industry,
    Company_Type,
    Headquarters
)

SELECT DISTINCT
    Company,
    Industry,
    Company_Type,
    Headquarters
FROM Raw_Trade_Data;
SELECT *
FROM Companies
LIMIT 10;
SELECT COUNT(*) AS Total_Companies
FROM Companies;

CREATE TABLE Ports
(
    Port_ID INT AUTO_INCREMENT PRIMARY KEY,
    Port_Name VARCHAR(100),
    State VARCHAR(100),
    Port_Type VARCHAR(50)
);
INSERT INTO Ports
(
    Port_Name,
    State,
    Port_Type
)

SELECT DISTINCT
    Port,
    State,
    Port_Type
FROM Raw_Trade_Data;
SELECT *
FROM Ports
LIMIT 10;
SELECT COUNT(*) AS Total_Ports
FROM Ports;

CREATE TABLE Trade_Transactions
(
    Transaction_ID INT PRIMARY KEY,
    Trade_Date DATE,
    Trade_Type VARCHAR(20),

    Country_ID INT,
    Product_ID INT,
    Company_ID INT,
    Port_ID INT,

    Shipment_Mode VARCHAR(20),

    Quantity INT,
    Unit_Price_USD DECIMAL(10,2),
    Freight_Cost DECIMAL(10,2),
    Insurance_Cost DECIMAL(10,2),
    Customs_Duty DECIMAL(10,2),
    Trade_Value_USD DECIMAL(12,2),

    Currency VARCHAR(10),
    Payment_Method VARCHAR(50),
    Status VARCHAR(30),
    Incoterm VARCHAR(20),

    CONSTRAINT fk_country
        FOREIGN KEY (Country_ID)
        REFERENCES Countries(Country_ID),

    CONSTRAINT fk_product
        FOREIGN KEY (Product_ID)
        REFERENCES Products(Product_ID),

    CONSTRAINT fk_company
        FOREIGN KEY (Company_ID)
        REFERENCES Companies(Company_ID),

    CONSTRAINT fk_port
        FOREIGN KEY (Port_ID)
        REFERENCES Ports(Port_ID)
);

SELECT
    r.Transaction_ID,
    c.Country_ID,
    p.Product_ID,
    co.Company_ID,
    po.Port_ID
FROM Raw_Trade_Data r
INNER JOIN Countries c
    ON TRIM(r.Country) = TRIM(c.Country_Name)
INNER JOIN Products p
    ON TRIM(r.Product) = TRIM(p.Product_Name)
INNER JOIN Companies co
    ON TRIM(r.Company) = TRIM(co.Company_Name)
INNER JOIN Ports po
    ON TRIM(r.Port) = TRIM(po.Port_Name)
LIMIT 10;

INSERT INTO Trade_Transactions
(
    Transaction_ID,
    Trade_Date,
    Trade_Type,
    Country_ID,
    Product_ID,
    Company_ID,
    Port_ID,
    Shipment_Mode,
    Quantity,
    Unit_Price_USD,
    Freight_Cost,
    Insurance_Cost,
    Customs_Duty,
    Trade_Value_USD,
    Currency,
    Payment_Method,
    Status,
    Incoterm
)

SELECT
    r.Transaction_ID,
    r.Trade_Date,
    r.Trade_Type,

    c.Country_ID,
    p.Product_ID,
    co.Company_ID,
    po.Port_ID,

    r.Shipment_Mode,
    r.Quantity,
    r.Unit_Price_USD,
    r.Freight_Cost,
    r.Insurance_Cost,
    r.Customs_Duty,
    r.Trade_Value_USD,
    r.Currency,
    r.Payment_Method,
    r.Status,
    r.Incoterm

FROM Raw_Trade_Data r

INNER JOIN Countries c
    ON TRIM(r.Country) = TRIM(c.Country_Name)

INNER JOIN Products p
    ON TRIM(r.Product) = TRIM(p.Product_Name)

INNER JOIN Companies co
    ON TRIM(r.Company) = TRIM(co.Company_Name)

INNER JOIN Ports po
    ON TRIM(r.Port) = TRIM(po.Port_Name);
    
    SELECT COUNT(*) AS Total_Rows
FROM Trade_Transactions;


-- =====================================================
-- Query 1: Total Trade Value by Trade Type
-- Purpose: Calculate the total trade value for
--          Imports and Exports.
-- =====================================================

SELECT
    Trade_Type,                                -- Import or Export
    SUM(Trade_Value_USD) AS Total_Trade_Value  -- Total trade value in USD
FROM Trade_Transactions

GROUP BY Trade_Type;

-- =====================================================
-- Query 2: Total Transactions by Trade Type
-- Purpose: Count the total number of Import
--          and Export transactions.
-- =====================================================

SELECT
    Trade_Type,                        -- Import or Export
    COUNT(*) AS Total_Transactions     -- Total transactions
FROM Trade_Transactions

GROUP BY Trade_Type;

-- =====================================================
-- Query 3: Top 10 Countries by Trade Value
-- Purpose: Display the top 10 countries with
--          the highest total trade value.
-- =====================================================

SELECT
    c.Country_Name,                               -- Country name
    SUM(t.Trade_Value_USD) AS Total_Trade_Value   -- Total trade value

FROM Trade_Transactions t

INNER JOIN Countries c
ON t.Country_ID = c.Country_ID

GROUP BY c.Country_Name

ORDER BY Total_Trade_Value DESC

LIMIT 10;


-- =====================================================
-- Query 4: Total Trade Value by Product Category
-- Purpose: Calculate the total trade value
--          for each product category.
-- =====================================================

SELECT
    p.Product_Category,                           -- Product category
    SUM(t.Trade_Value_USD) AS Total_Trade_Value   -- Total trade value

FROM Trade_Transactions t

INNER JOIN Products p
ON t.Product_ID = p.Product_ID

GROUP BY p.Product_Category

ORDER BY Total_Trade_Value DESC;


-- =====================================================
-- Query 5: Monthly Trade Value Trend
-- Purpose: Analyze monthly trade value trends
--          over different years.
-- =====================================================

SELECT
    YEAR(Trade_Date) AS Trade_Year,               -- Trade year

    MONTH(Trade_Date) AS Trade_Month,             -- Trade month

    SUM(Trade_Value_USD) AS Total_Trade_Value     -- Monthly trade value

FROM Trade_Transactions

GROUP BY
    YEAR(Trade_Date),
    MONTH(Trade_Date)

ORDER BY
    Trade_Year,
    Trade_Month;
    
    -- =====================================================
-- Query 6: Top 5 Companies by Total Trade Value
-- Purpose: Find the top 5 companies with the
--          highest total trade value.
-- =====================================================

SELECT
    c.Company_Name,                               -- Company name
    SUM(t.Trade_Value_USD) AS Total_Trade_Value   -- Total trade value

FROM Trade_Transactions t

INNER JOIN Companies c
ON t.Company_ID = c.Company_ID

GROUP BY c.Company_Name

ORDER BY Total_Trade_Value DESC

LIMIT 5;

-- =====================================================
-- Query 7: Total Trade Value by Shipment Mode
-- Purpose: Calculate the total trade value
--          for each shipment mode.
-- =====================================================

SELECT
    Shipment_Mode,                               -- Shipment mode (Air, Sea, Road, Rail)
    SUM(Trade_Value_USD) AS Total_Trade_Value    -- Total trade value

FROM Trade_Transactions

GROUP BY Shipment_Mode

ORDER BY Total_Trade_Value DESC;

-- =====================================================
-- Query 8: Average Trade Value by Country
-- Purpose: Calculate the average trade value
--          for each country.
-- =====================================================

SELECT
    c.Country_Name,                               -- Country name
    AVG(t.Trade_Value_USD) AS Average_Trade_Value -- Average trade value

FROM Trade_Transactions t

INNER JOIN Countries c
ON t.Country_ID = c.Country_ID

GROUP BY c.Country_Name

ORDER BY Average_Trade_Value DESC;

-- =====================================================
-- Query 9: Top 5 Ports by Total Trade Value
-- Purpose: Find the top 5 ports handling the
--          highest total trade value.
-- =====================================================

SELECT
    p.Port_Name,                                -- Port name
    SUM(t.Trade_Value_USD) AS Total_Trade_Value -- Total trade value

FROM Trade_Transactions t

INNER JOIN Ports p
ON t.Port_ID = p.Port_ID

GROUP BY p.Port_Name

ORDER BY Total_Trade_Value DESC

LIMIT 5;

-- =====================================================
-- Query 10: Trade Value by Payment Method
-- Purpose: Analyze the total trade value and
--          number of transactions for each
--          payment method.
-- =====================================================

SELECT
    Payment_Method,                              -- Payment method
    COUNT(*) AS Total_Transactions,              -- Number of transactions
    SUM(Trade_Value_USD) AS Total_Trade_Value    -- Total trade value

FROM Trade_Transactions

GROUP BY Payment_Method

ORDER BY Total_Trade_Value DESC;


-- ==========================================
-- View 1: Trade Summary
-- Purpose: Display trade details with
--          country, company, product and port.
-- ==========================================

CREATE VIEW Trade_Summary AS

SELECT
    t.Transaction_ID,
    t.Trade_Date,
    t.Trade_Type,
    c.Country_Name,
    p.Product_Name,
    co.Company_Name,
    po.Port_Name,
    t.Trade_Value_USD

FROM Trade_Transactions t

JOIN Countries c
ON t.Country_ID = c.Country_ID

JOIN Products p
ON t.Product_ID = p.Product_ID

JOIN Companies co
ON t.Company_ID = co.Company_ID

JOIN Ports po
ON t.Port_ID = po.Port_ID;

SELECT *
FROM Trade_Summary
LIMIT 10;

DELIMITER //

CREATE PROCEDURE GetCountryTrade
(
    IN CountryName VARCHAR(100)
)

BEGIN

SELECT
    c.Country_Name,
    SUM(t.Trade_Value_USD) AS Total_Trade

FROM Trade_Transactions t

JOIN Countries c
ON t.Country_ID = c.Country_ID

WHERE c.Country_Name = CountryName

GROUP BY c.Country_Name;

END //

DELIMITER ;

SELECT VERSION();

SHOW TABLES;

SELECT COUNT(*) AS Raw_Data_Rows
FROM Raw_Trade_Data;

SELECT COUNT(*) AS Fact_Table_Rows
FROM Trade_Transactions;