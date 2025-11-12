create database if not exists pizza;
use  pizza;
SELECT 
    InvoiceNo, StockCode, Quantity, InvoiceDate, COUNT(*) AS duplicate_count
FROM data
GROUP BY InvoiceNo, StockCode, Quantity, InvoiceDate
HAVING COUNT(*) > 1;

SELECT DISTINCT *
FROM data;

CREATE TABLE clean_data AS
SELECT 
    InvoiceNo,
    StockCode,
    MIN(Description) AS Description,
    Quantity,
    MIN(InvoiceDate) AS InvoiceDate,
    MIN(UnitPrice) AS UnitPrice,
    MIN(CustomerID) AS CustomerID,
    MIN(Country) AS Country
FROM data
GROUP BY InvoiceNo, StockCode, Quantity, InvoiceDate;


SELECT COUNT(*) - COUNT(DISTINCT InvoiceNo, StockCode, Quantity, InvoiceDate) AS remaining_duplicates
FROM clean_data;


SELECT * 
FROM clean_data
WHERE CustomerID IS NULL OR Description IS NULL OR UnitPrice IS NULL;

ALTER TABLE clean_data ADD COLUMN TotalPrice DECIMAL(10,2);

SET SQL_SAFE_UPDATES = 0;
UPDATE clean_data
SET TotalPrice = Quantity * UnitPrice;


#Helps for time-based reports (monthly, daily, etc.)
UPDATE clean_data
SET InvoiceDate = STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i');

#Top-selling products:
SELECT Description, SUM(TotalPrice) AS Revenue
FROM clean_data
GROUP BY Description
ORDER BY Revenue DESC
LIMIT 10;

#selles by country
SELECT Country, SUM(TotalPrice) AS TotalRevenue
FROM clean_data
GROUP BY Country
ORDER BY TotalRevenue DESC;

#Best customers:
SELECT CustomerID, SUM(TotalPrice) AS CustomerSpend
FROM clean_data
GROUP BY CustomerID
ORDER BY CustomerSpend DESC
LIMIT 10;

#Total Revenue per Country
SELECT 
    Country,
    ROUND(SUM(TotalPrice), 2) AS Total_Revenue
FROM clean_data
GROUP BY Country
ORDER BY Total_Revenue DESC;

#Total Revenue per Customer
SELECT 
    CustomerID,
    ROUND(SUM(TotalPrice), 2) AS Total_Revenue
FROM clean_data
GROUP BY CustomerID
ORDER BY Total_Revenue DESC;


#Monthly Sales Trends
SELECT 
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month,
    ROUND(SUM(TotalPrice), 2) AS Monthly_Sales
FROM clean_data
GROUP BY Month
ORDER BY Month;

#Daily Sales Trends
SELECT 
    DATE(InvoiceDate) AS Sale_Date,
    ROUND(SUM(TotalPrice), 2) AS Daily_Sales
FROM clean_data
GROUP BY Sale_Date
ORDER BY Sale_Date;

#Average Spending per Customer
SELECT 
    ROUND(AVG(TotalPrice), 2) AS Avg_Spending
FROM clean_data
GROUP BY CustomerID
ORDER BY Avg_Spending DESC;



















