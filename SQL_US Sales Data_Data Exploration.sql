SELECT *
FROM Portfolio_Project.dbo.[Sales Orders Sheet]

SELECT *
FROM Portfolio_Project.dbo.[Sales Team Sheet]

--What's the most popular product being sold?
--What's the most successful channel for sales for this product?
--Who are the largest buyers? 



--Join tables to match up IDs with names 
--Add on columns to original table first, for Customers names and product names
ALTER TABLE
Portfolio_Project.dbo.[Sales Orders Sheet]
ADD Product_Name Nvarchar(255)

ALTER TABLE
Portfolio_Project.dbo.[Sales Orders Sheet]
ADD Customer_Name Nvarchar(255)



--Dealing with Product IDs to match up to Product_Names from the Product ID table.
SELECT 
[Sales Orders Sheet]._ProductID AS Sales_ProductID,
[Products Sheet].[Product Name],
ISNULL([Sales Orders Sheet].Product_Name, [Products Sheet].[Product Name])
FROM
Portfolio_Project.dbo.[Sales Orders Sheet] 
JOIN Portfolio_Project.dbo.[Products Sheet] 
ON [Sales Orders Sheet]._ProductID = [Products Sheet]._ProductID
WHERE
Portfolio_Project.dbo.[Sales Orders Sheet].Product_Name is NULL

--Updating 
UPDATE Portfolio_Project.dbo.[Sales Orders Sheet]
SET 
Product_Name = ISNULL([Sales Orders Sheet].Product_Name, [Products Sheet].[Product Name])
FROM
Portfolio_Project.dbo.[Sales Orders Sheet] 
JOIN Portfolio_Project.dbo.[Products Sheet] 
ON [Sales Orders Sheet]._ProductID = [Products Sheet]._ProductID
WHERE
Portfolio_Project.dbo.[Sales Orders Sheet].Product_Name is NULL

SELECT *
FROM Portfolio_Project.dbo.[Sales Orders Sheet]



--Customer IDs to match up to Customer_names table
SELECT 
[Sales Orders Sheet]._CustomerID AS Customer_ID,
[Customers Sheet].[Customer Names],
ISNULL([Sales Orders Sheet].Customer_Name, [Customers Sheet].[Customer Names])
FROM
Portfolio_Project.dbo.[Sales Orders Sheet] 
JOIN Portfolio_Project.dbo.[Customers Sheet] 
ON [Sales Orders Sheet]._CustomerID = [Customers Sheet]._CustomerID
WHERE
Portfolio_Project.dbo.[Sales Orders Sheet].Customer_Name is NULL

--Updating 
UPDATE Portfolio_Project.dbo.[Sales Orders Sheet]
SET 
Customer_Name = ISNULL([Sales Orders Sheet].Customer_Name, [Customers Sheet].[Customer Names])
FROM
Portfolio_Project.dbo.[Sales Orders Sheet] 
JOIN Portfolio_Project.dbo.[Customers Sheet] 
ON [Sales Orders Sheet]._CustomerID = [Customers Sheet]._CustomerID
WHERE
Portfolio_Project.dbo.[Sales Orders Sheet].Customer_Name is NULL



--Calculating profits
--First add column
SELECT *
FROM Portfolio_Project.dbo.[Sales Orders Sheet]

ALTER TABLE
Portfolio_Project.dbo.[Sales Orders Sheet]
ADD Unit_Net_Profit int 

UPDATE Portfolio_Project.dbo.[Sales Orders Sheet]
SET 
Unit_Net_Profit = [Unit Price]-[Unit Cost]



--Create tables for Tableau Imports
SELECT DISTINCT([Sales Channel])
FROM Portfolio_Project.dbo.[Sales Orders Sheet]




--TABLE 1 - Frequency of purchases per medium/ outlet
SELECT 
[Sales Channel], COUNT([Sales Channel]) AS Purchase_Frequency
FROM 
Portfolio_Project.dbo.[Sales Orders Sheet]
WHERE Product_Name = 'Serveware'
GROUP BY 
[Sales Channel]



--TABLE 2 - Total profits by product 
SELECT 
[Product_Name], SUM([Unit_Net_Profit]) AS Net_Profits
FROM 
Portfolio_Project.dbo.[Sales Orders Sheet]
GROUP BY 
[Product_Name]
ORDER BY 
Net_Profits DESC

--Profit by products in store
SELECT 
[Product_Name], SUM([Unit_Net_Profit]) AS Store_Net_Profits
FROM 
Portfolio_Project.dbo.[Sales Orders Sheet]
WHERE [Sales Channel] = 'In-Store'
GROUP BY 
[Product_Name]
ORDER BY 
Store_Net_Profits DESC

--Profit by products online
SELECT 
[Product_Name], SUM([Unit_Net_Profit]) AS Online_Net_Profits
FROM 
Portfolio_Project.dbo.[Sales Orders Sheet]
WHERE [Sales Channel] = 'Online'
GROUP BY 
[Product_Name]
ORDER BY 
Online_Net_Profits DESC

--Profit by products through wholesale
SELECT 
[Product_Name], SUM([Unit_Net_Profit]) AS Wholesale_Net_Profits
FROM 
Portfolio_Project.dbo.[Sales Orders Sheet]
WHERE [Sales Channel] = 'Wholesale'
GROUP BY 
[Product_Name]
ORDER BY 
Wholesale_Net_Profits DESC

--Profits through distributors
SELECT 
[Product_Name], SUM([Unit_Net_Profit]) AS Distributor_Net_Profits
FROM 
Portfolio_Project.dbo.[Sales Orders Sheet]
WHERE [Sales Channel] = 'Distributor'
GROUP BY 
[Product_Name]
ORDER BY 
Distributor_Net_Profits DESC
--Sort all the above in excel and import into Tableau


--TABLE 4 - Largest buyers
SELECT *
FROM Portfolio_Project.dbo.[Sales Orders Sheet]

SELECT [Customer_Name], SUM([Unit_Net_Profit]) AS Customer_Purchases
FROM Portfolio_Project.dbo.[Sales Orders Sheet]
GROUP BY
[Customer_Name]
ORDER BY Customer_Purchases DESC

--Largest buyer of the most profitable product
SELECT [Customer_Name], SUM([Unit_Net_Profit]) AS Customer_Purchases
FROM Portfolio_Project.dbo.[Sales Orders Sheet]
WHERE Product_Name = 'Serveware' 
GROUP BY
[Customer_Name]
ORDER BY Customer_Purchases DESC

--Demand for Serveware by company (frequency)
SELECT 
Customer_Name, COUNT(Product_Name) AS Product_Frequency
FROM 
Portfolio_Project.dbo.[Sales Orders Sheet]
WHERE Product_Name = 'Serveware' 
GROUP BY 
Customer_Name

--How to target highest buyer with most profitable product
SELECT 
[Sales Channel], COUNT([Sales Channel]) AS Purchase_Frequency
FROM 
Portfolio_Project.dbo.[Sales Orders Sheet]
WHERE Product_Name = 'Serveware' AND Customer_Name = 'Dharma Ltd'
GROUP BY 
[Sales Channel]

--For a new store, if in-store purchases are the most profitable, location may be most important which is also most costly. Make a suggestion for a Product through Online which may be cheaper.

--TABLE 5 - Sales of Serveware over time
SELECT CAST(OrderDate as date) AS Order_Date, Unit_Net_Profit
FROM Portfolio_Project.dbo.[Sales Orders Sheet]
WHERE Product_Name = 'Serveware'
ORDER BY Order_Date 


