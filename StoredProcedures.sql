use WideWorldImporters;

GO
CREATE PROC Sales.GetCustomerOrders     
	@custid AS INT
	, @orderdatefrom AS DATETIME = '19000101'
	, @orderdateto   AS DATETIME = '99991231'
	, @numrows  AS INT = 0 OUTPUT 
	AS
	BEGIN     
	SET NOCOUNT ON;  
	SELECT orderid, CustomerID, orderdate
	FROM [Sales].[Orders]     
	WHERE CustomerID = @custid AND 
	orderdate >= @orderdatefrom AND
	orderdate < @orderdateto;  
	SET @numrows = @@ROWCOUNT;  
	RETURN;
	END

GO
EXEC Sales.GetCustomerOrders  @custid = 37, @orderdatefrom = '20070401', @orderdateto  = '20070701';
GO

SELECT * 
FROM Sales.Orders  ;

DECLARE @var1 AS INT, @var2 AS INT;
SET @var1 = 1; SET @var2 = 1; 
IF @var1 = @var2    
	PRINT 'The variables are equal';
ELSE    
	PRINT 'The variables are not equal';
GO

GO 
SET NOCOUNT ON;
DECLARE @count AS INT = 1;
WHILE @count <= 100   
BEGIN        
	IF @count = 17   
	BREAK;       
	IF @count = 5         
	BEGIN               
		SET @count += 2;                
		CONTINUE;   
	END       
	PRINT CAST(@count AS NVARCHAR);      
	SET @count += 1; 
END;

GO
IF OBJECT_ID('Sales.tr_SalesOrderDetailsDML', 'TR') IS NOT NULL    
DROP TRIGGER Sales.tr_SalesOrderDetailsDML; 
GO
CREATE TRIGGER Sales.tr_SalesOrderDetailsDML 
ON Sales.OrderLines
AFTER DELETE, INSERT, UPDATE
AS 
BEGIN
SET NOCOUNT ON 
END
GO

-- @@ROWCOUNT will contain the number of rows affected by the outer INSERT, UpDaTE, or DELETE statement

IF OBJECT_ID('Sales.tr_SalesOrderDetailsDML', 'TR') IS NOT NULL   
DROP TRIGGER Sales.tr_SalesOrderDetailsDML; 
GO
CREATE TRIGGER Sales.tr_SalesOrderDetailsDML2
ON Sales.ORDERlINES AFTER DELETE, INSERT, UPDATE
AS
BEGIN  
IF @@ROWCOUNT = 0 
RETURN; 
SET NOCOUNT ON;  
SELECT COUNT(*) AS InsertedCount 
FROM Inserted;   
SELECT COUNT(*) AS DeletedCount
FROM Deleted;
END;

IF OBJECT_ID('Sales.tr_SalesMyCustomers_customername', 'TR') IS NOT NULL    
	DROP TRIGGER Sales.tr_SalesMyCustomers_customername;

GO 
CREATE TRIGGER Sales.tr_SalesMyCustomers_customername
ON Sales.MyCustomers 
AFTER INSERT, UPDATE
AS
BEGIN 
	IF @@ROWCOUNT = 0 RETURN;   
	SET NOCOUNT ON; 
	IF EXISTS (SELECT COUNT(*)      
		FROM Inserted AS I  -- table with inserted rows
		JOIN Sales.MyCustomers  AS C      
			ON I.CustomerName = C.CustomerName   
		GROUP BY I.CustomerName    
		HAVING COUNT(*) > 1 )	

	BEGIN    
		THROW 50000, 'Duplicate category names not allowed', 0;   
	END; 
END; 
GO

INSERT INTO Sales.MyCustomers(CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, ValidFrom, ValidTo)  
	VALUES (664, 'TestCategory1', 1, 3, 1, 1003, '2013-01-01 00:00:00.0000000', '9999-12-31 23:59:59.9999999');

SELECT * 
FROM Sales.MyCustomers;

SELECT *
FROM Sales.MyOrders;

----- Trigger for Sales.MyOrders --- AFTER -----

IF OBJECT_ID('Sales.tr_SalesMyOrders_orderdate', 'TR') IS NOT NULL    
	DROP TRIGGER Sales.tr_SalesMyOrders_orderdate;

GO 
CREATE TRIGGER Sales.tr_SalesMyOrders_orderdate
ON Sales.MyOrders 
AFTER INSERT, UPDATE
AS
BEGIN 
	IF @@ROWCOUNT = 0 RETURN;   
	SET NOCOUNT ON; -- don't return rowscount
	IF EXISTS (SELECT COUNT(*)      
		FROM Inserted AS I  -- table with inserted rows
		JOIN Sales.MyOrders  AS O   
			ON I.orderdate = O.orderdate   
		GROUP BY I.orderdate    
		HAVING COUNT(*) > 1 )	

	BEGIN    
		THROW 50000, 'Duplicate order dates not allowed', 0;   
	END; 
END; 
GO

INSERT INTO Sales.MyOrders(orderid, custid, empid, orderdate)  
	VALUES (7, 70, 1, '2013-01-01'); -- creates trigger regarding insert value

UPDATE Sales.MyOrders
SET orderdate = '2014-01-01'
WHERE orderid = 7;

-------------------------------------------

IF OBJECT_ID('Sales.tr_SalesMyOrders_orderdate', 'TR') IS NOT NULL    
	DROP TRIGGER Sales.tr_SalesMyOrders_orderdate;

GO 
CREATE TRIGGER Sales.tr_SalesMyOrders_orderdate
ON Sales.MyOrders 
INSTEAD OF INSERT
AS
BEGIN 
	IF @@ROWCOUNT = 0 RETURN;   
	SET NOCOUNT ON; 
	IF EXISTS (SELECT COUNT(*)      
		FROM Inserted AS I  
		JOIN Sales.MyOrders  AS O   
			ON I.orderdate = O.orderdate   
		GROUP BY I.orderdate    
		HAVING COUNT(*) > 1 )	

	BEGIN    
		THROW 50000, 'Duplicate order dates not allowed', 0;   
	END; 
END; 
GO

------- Temporary tables ------ 

CREATE TABLE #T1 (   col1 INT NOT NULL ); 
 
INSERT INTO #T1(col1) VALUES(10); 
 
EXEC('SELECT col1 FROM #T1;'); GO 
 
SELECT col1 FROM #T1; GO 
 
DROP TABLE #T1; GO