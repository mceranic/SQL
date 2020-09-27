IF OBJECT_ID('Sales.MyOrders') IS NOT NULL DROP TABLE Sales.MyOrders; GO 
 
CREATE TABLE Sales.MyOrders 
(   
	orderid INT NOT NULL IDENTITY(1, 1)     
	CONSTRAINT PK_MyOrders_orderid PRIMARY KEY
	, custid  INT NOT NULL
	, empid   INT NOT NULL
	, orderdate DATE NOT NULL     
	CONSTRAINT DFT_MyOrders_orderdate DEFAULT (CAST(SYSDATETIME() AS DATE))
	, shipcountry NVARCHAR(15) NOT NULL
	, freight MONEY NOT NULL 
);

INSERT INTO Sales.MyOrders(custid, empid, orderdate, shipcountry, freight)   
	VALUES(2, 19, '20120620', N'USA', 30.00);

INSERT INTO Sales.MyOrders(custid, empid, orderdate, shipcountry, freight) 
VALUES   (2, 11, '20120620', N'USA', 50.00),   
		 (5, 13, '20120620', N'USA', 40.00),   
		 (7, 17, '20120620', N'USA', 45.00);


CREATE TABLE Sales.TempOrders 
(   
	orderid INT NOT NULL IDENTITY(1, 1)     
	CONSTRAINT PK_TempOrders_orderid PRIMARY KEY
	, custid  INT NOT NULL
	, orderdate DATE NOT NULL     
	CONSTRAINT DFT_TempOrders_orderdate DEFAULT (CAST(SYSDATETIME() AS DATE))
);

SET IDENTITY_INSERT Sales.TempOrders ON; 
 
INSERT INTO Sales.TempOrders(orderid, custid, orderdate)   
SELECT OrderID, CustomerID, orderdate
FROM Sales.Orders
WHERE OrderID < 10;
 
SET IDENTITY_INSERT Sales.TempOrders OFF;

SELECT * 
FROM Sales.TempOrders;

IF OBJECT_ID('Application.LatestRecordedPopulationForCities', 'P') IS NOT NULL   
DROP PROC Application.LatestRecordedPopulationForCities; 
GO 
 
CREATE PROC Application.LatestRecordedPopulationForCities  @city AS NVARCHAR(15) AS 
 
SELECT CityID, CityName, LatestRecordedPopulation
FROM Application.Cities 
WHERE CityName = @city; 
GO

CREATE TABLE Application.TempCities 
(   
	cityid INT NOT NULL IDENTITY(1, 1)     
	CONSTRAINT PK_TempCities_cityid PRIMARY KEY
	, cityname  NVARCHAR(15) NOT NULL
	, LatestRecordedPopulation INT NOT NULL     
);

SET IDENTITY_INSERT Application.TempCities ON; 
 
INSERT INTO Application.TempCities(cityid, cityname, LatestRecordedPopulation)   
	EXEC Application.LatestRecordedPopulationForCities     
	@city = N'Abbeville'; 
 
SET IDENTITY_INSERT Application.TempCities OFF;

SELECT * 
FROM Application.TempCities;

IF OBJECT_ID('Sales.MyOrderLines', 'U') IS NOT NULL   
DROP TABLE Sales.MyOrderLines; 

IF OBJECT_ID('Sales.MyOrders', 'U') IS NOT NULL   
DROP TABLE Sales.MyOrders; 

IF OBJECT_ID('Sales.MyCustomers', 'U') IS NOT NULL   
DROP TABLE Sales.MyCustomers; 
 
SELECT * INTO Sales.MyCustomers FROM Sales.Customers; 
ALTER TABLE Sales.MyCustomers   
ADD CONSTRAINT PK_MyCustomers PRIMARY KEY(customerid); 
 
SELECT * INTO Sales.MyOrders FROM Sales.Orders; 
ALTER TABLE Sales.MyOrders   
ADD CONSTRAINT PK_MyOrders PRIMARY KEY(orderid); 
 
SELECT * INTO Sales.MyOrderLines FROM Sales.OrderLines; 
ALTER TABLE Sales.MyOrderLines   
ADD CONSTRAINT PK_MyOrderLines PRIMARY KEY(orderlineid);

SELECT * 
FROM Sales.MyOrderLines 
WHERE orderid = 10251;

SELECT * 
FROM Sales.MyOrderLines

SELECT * 
FROM Sales.MyCustomers

SELECT * 
FROM Sales.MyOrders

-- UPDATE --

UPDATE Sales.MyOrderLines   
	SET UnitPrice -= 0.05 
WHERE orderid = 10251;

DELETE FROM Sales.MyOrders 
WHERE EXISTS(
SELECT *    
FROM Sales.MyCustomers    
WHERE MyCustomers.CustomerID = MyOrders.CustomerID AND MyCustomers.PostalAddressLine2 = N'Nairville'
);

SELECT * 
FROM Sales.MyOrderLines 
WHERE orderid = 2   AND StockItemID = 10;

DECLARE @newquantity AS int = 0; 

UPDATE Sales.MyOrderLines   
	SET @newquantity = quantity -= 1  -- sve odjednom izvrsavati  
	WHERE orderid = 2   AND StockItemID = 10;
 
SELECT @newquantity;

------------------------------------

IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL 
DROP TABLE dbo.T1; 
 
CREATE TABLE dbo.T1 
(   
	keycol INT NOT NULL     
	CONSTRAINT PK_T1 PRIMARY KEY
	, col1 INT NOT NULL
	, col2 INT NOT NULL 
); 
 
INSERT INTO dbo.T1(keycol, col1, col2) 
	VALUES(1, 100, 0);

DECLARE @add AS INT = 10; 
 
UPDATE dbo.T1   
	SET col1 += @add, col2 = col1
	WHERE keycol = 1; 
 
SELECT * FROM dbo.T1;

SELECT C.CustomerID, C.PostalPostalCode, O.DeliveryInstructions 
FROM Sales.MyCustomers AS C   
JOIN Sales.MyOrders AS O    
ON C.CustomerID = O.CustomerID 
ORDER BY C.CustomerID;

SELECT StockItemID, COUNT(*) as numstock
FROM Sales.MyOrderLines 
where StockItemID = 23
GROUP BY StockItemID;

