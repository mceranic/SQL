USE WideWorldImporters;

CREATE TABLE Sales.Categories(     
categoryid INT IDENTITY(1,1) NOT NULL,     
categoryname NVARCHAR(15) NOT NULL,     
description NVARCHAR(200) NOT NULL) 
GO

ALTER TABLE Sales.Categories     
	ADD CONSTRAINT PK_Categories PRIMARY KEY(categoryid);
GO

SELECT * FROM Sales.Categories;

GO 
CREATE TABLE Sales.CategoriesTest 
(   
categoryid INT NOT NULL IDENTITY 
); 
GO

ALTER TABLE Sales.CategoriesTest     
	ADD categoryname NVARCHAR(15) NOT NULL; 
GO 
ALTER TABLE Sales.CategoriesTest     
	ADD description NVARCHAR(200) NOT NULL; 
GO

SET IDENTITY_INSERT Sales.CategoriesTest ON; 
INSERT Sales.CategoriesTest (categoryid, categoryname, description)     
SELECT categoryid, categoryname, description     
FROM Sales.Categories; 
GO 
SET IDENTITY_INSERT Sales.CategoriesTest OFF; 
GO

ALTER TABLE Sales.CategoriesTest    
	ALTER COLUMN description NVARCHAR(500) NOT NULL ; 
GO

SELECT description     
FROM Sales.CategoriesTest      
WHERE categoryid = 8; -- Seaweed and fish

UPDATE Sales.CategoriesTest     
	SET description = NULL      
	WHERE categoryid = 8; 
GO

-- If table already exist, delete it
IF OBJECT_ID('Production.CategoriesTest','U') IS NOT NULL      
DROP TABLE Production.CategoriesTest; GO

SELECT * FROM Sales.CategoriesTest;

-- VIEWS --

IF OBJECT_ID('Sales.OrderTotalsByYear', 'V') IS NOT NULL     
DROP VIEW Sales.OrderTotalsByYear;  

GO  
CREATE VIEW Sales.OrderTotalsByYear   
WITH SCHEMABINDING 
AS 
SELECT   YEAR(O.orderdate) AS orderyear,   
SUM(OL.Quantity) AS qty
FROM Sales.Orders AS O   
	JOIN Sales.OrderLines AS OL  
ON OL.orderid = O.orderid 
GROUP BY YEAR(orderdate); 
GO

SELECT orderyear, qty 
FROM Sales.OrderTotalsByYear;

-- check existing views in database

GO 
SELECT name, object_id, principal_id, schema_id, type  
FROM sys.views;

SELECT  TABLE_NAME, TABLE_TYPE  
FROM INFORMATION_SCHEMA.TABLES  
WHERE TABLE_TYPE = 'VIEW';

----------------------------------------

GO 
IF OBJECT_ID (N'Sales.fn_OrderTotalsByYear', N'IF') IS NOT NULL     
DROP FUNCTION Sales.fn_OrderTotalsByYear; 
GO 
CREATE FUNCTION Sales.fn_OrderTotalsByYear () 
RETURNS TABLE 
AS 
RETURN     
(
SELECT YEAR(O.orderdate) AS orderyear, SUM(OL.Quantity) AS Quantity     
FROM Sales.Orders AS O       
JOIN Sales.OrderLines AS OL         
ON OL.orderid = O.orderid     
GROUP BY YEAR(orderdate)     
); 
GO

SELECT TOP(100) * 
from Sales.fn_OrderTotalsByYear() AS OTY;

GO 
IF OBJECT_ID (N'Sales.fn_OrderTotalsByYear', N'IF') IS NOT NULL     
DROP FUNCTION Sales.fn_OrderTotalsByYear; 
GO 
CREATE FUNCTION Sales.fn_OrderTotalsByYear () 
RETURNS TABLE 
AS 
RETURN     
(     
SELECT orderyear, qty 
FROM Sales.OrderTotalsByYear      
); 
GO

SELECT TOP(100) * 
from Sales.fn_OrderTotalsByYear() AS OTY;

DECLARE @orderyear int = 2015; 
SELECT orderyear, qty  
FROM Sales.OrderTotalsByYear 
WHERE orderyear = @orderyear;

GO 
IF OBJECT_ID (N'Sales.fn_OrderTotalsByYear', N'IF') IS NOT NULL     
DROP FUNCTION Sales.fn_OrderTotalsByYear; 
GO 
CREATE FUNCTION Sales.fn_OrderTotalsByYear (@orderyear int) 
RETURNS TABLE 
AS 
RETURN      
(     
SELECT orderyear, qty 
FROM Sales.OrderTotalsByYear      
WHERE orderyear = @orderyear     
); 
GO

DECLARE @orderyear int = 2015;
SELECT TOP(1) * 
from Sales.fn_OrderTotalsByYear(@orderyear) AS OTY;

SELECT  orderyear, qty FROM Sales.fn_OrderTotalsByYear(2015);

-- create synonyms

GO 
CREATE SYNONYM dbo.Orders FOR Sales.Orders; 
GO

SELECT * 
FROM Orders;

DROP SYNONYM dbo.Orders;

----------------------------

IF OBJECT_ID('Sales.MyOrders') IS NOT NULL 
DROP TABLE Sales.MyOrders; 
GO 
 
CREATE TABLE Sales.MyOrders
(   orderid INT NOT NULL IDENTITY(1, 1)    
	CONSTRAINT PK_MyOrders_orderid PRIMARY KEY
	, custid  INT NOT NULL     
	CONSTRAINT CHK_MyOrders_custid CHECK(custid > 0)
	, empid   INT NOT NULL     
	CONSTRAINT CHK_MyOrders_empid CHECK(empid > 0)
	, orderdate DATE NOT NULL 
);

SELECT *
FROM Sales.MyOrders;

INSERT INTO Sales.MyOrders(custid, empid, orderdate) 
	VALUES   (1, 2, '20120620')
	, (1, 3, '20120620')
	, (2, 2, '20120620')
	, (2, 2, '20120620');

SELECT SCOPE_IDENTITY()  AS SCOPE_IDENTITY
       , @@IDENTITY AS [@@IDENTITY]
	   , IDENT_CURRENT('Sales.MyOrders') AS IDENT_CURRENT;

TRUNCATE TABLE Sales.MyOrders;  -- return IDENT_CURRENT on initial value 1

SELECT IDENT_CURRENT('Sales.MyOrders') AS [IDENT_CURRENT];

DELETE FROM Sales.MyOrders;  -- IDENT_CURRENT stays sam as the last one

----------------------------------------------

DECLARE @T1 AS TABLE ( 
	col1 INT NOT NULL 
); 
 
INSERT INTO @T1(col1) 
	VALUES(10); 
 
SELECT name FROM tempdb.sys.objects WHERE name LIKE '#%';

---- Statistics

SET STATISTICS IO ON;

CREATE TABLE #T1 ( 
	col1 INT  NOT NULL
	, col2 INT  NOT NULL
	, col3 DATE NOT NULL
	, PRIMARY KEY(col1)
	, UNIQUE(col2) 
);

INSERT INTO #T1(col1, col2, col3) 
SELECT n, n * 2, CAST(SYSDATETIME() AS DATE) 
FROM dbo.GetNums(1, 1000000);

SELECT * 
FROM SALES.CUSTOMERS;

SELECT * 
FROM SALES.CustomerTransactions;

SELECT C.CustomerName, SUM(CT.AmountExcludingTax) as TAX
FROM SALES.CustomerTransactions as CT 
 left join Sales.Customers as C on c.CustomerID = CT.CustomerID
GROUP BY C.CustomerName;