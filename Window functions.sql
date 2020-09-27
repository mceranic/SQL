use WideWorldImporters;

SELECT O.CustomerID, O.OrderID, OL.Quantity,
SUM(OL.Quantity) OVER(PARTITION BY O.CustomerID) AS CustomerTotal,   
SUM(OL.Quantity) OVER() AS GrandTotal
FROM Sales.OrderLines AS OL 
     join Sales.Orders AS O ON O.OrderID = OL.OrderID;

-- following query computes for each order the percent of --
-- the current order value out of the customer total, and also the percent of the grand total --

SELECT O.CustomerID, O.OrderID, OL.Quantity,
CAST(100.0 * OL.Quantity / SUM(OL.Quantity) OVER(PARTITION BY O.CustomerID) AS NUMERIC(5, 2)) AS pctcust, 
CAST(100.0 * OL.Quantity / SUM(OL.Quantity) OVER() AS NUMERIC(5, 2)) AS pcttotal
FROM Sales.OrderLines AS OL 
     join Sales.Orders AS O ON O.OrderID = OL.OrderID;

-- query the Sales.OrderValues view and compute the running total values from the beginning of 
-- the current customer’s activity until the current order

SELECT O.CustomerID, O.OrderID, O.OrderDate, OL.Quantity,
SUM(OL.Quantity) OVER(ORDER BY O.OrderDate, O.OrderID            
					  ROWS BETWEEN UNBOUNDED PRECEDING     
					  AND CURRENT ROW) AS RunningTotal
FROM Sales.OrderLines AS OL 
     join Sales.Orders AS O ON O.OrderID = OL.OrderID;

-- where RunningTotal < 1000.00

WITH RunningTotals AS 
(
SELECT O.CustomerID, O.OrderID, O.OrderDate, OL.Quantity,
SUM(OL.Quantity) OVER(ORDER BY O.OrderDate, O.OrderID            
					  ROWS BETWEEN UNBOUNDED PRECEDING     
					  AND CURRENT ROW) AS RunningTotal
FROM Sales.OrderLines AS OL 
     join Sales.Orders AS O ON O.OrderID = OL.OrderID
)
SELECT * 
FROM RunningTotals
WHERE RunningTotal < 1000.00;

WITH RunningTotals AS 
(
SELECT O.CustomerID, O.OrderID, O.OrderDate, OL.Quantity,
SUM(OL.Quantity) OVER(ORDER BY O.OrderDate, O.OrderID            
					  ROWS BETWEEN 2 PRECEDING     
					  AND CURRENT ROW) AS RunningTotal
FROM Sales.OrderLines AS OL 
     join Sales.Orders AS O ON O.OrderID = OL.OrderID
)
SELECT * 
FROM RunningTotals
WHERE RunningTotal < 1000.00;

-- Ranking functions --

SELECT O.CustomerID, O.OrderID, OL.Quantity,
ROW_NUMBER() OVER(ORDER BY OL.Quantity) AS rownum,
RANK() OVER(ORDER BY OL.Quantity) AS rnk,
DENSE_RANK() OVER(ORDER BY OL.Quantity) AS densernk,  
NTILE(100)   OVER(ORDER BY OL.Quantity) AS ntile100 
FROM Sales.OrderLines AS OL 
     join Sales.Orders AS O ON O.OrderID = OL.OrderID;

------------ LAG and LEAD ---------------------------------------

SELECT O.CustomerID, O.OrderID, OL.Quantity, 
LAG(OL.Quantity, 2, 0) OVER(PARTITION BY O.CustomerID   -- value before current offset; 2. parameter shows how many previous values will be skipped;
					   ORDER BY O.OrderDate, O.OrderID) AS prev_val,   -- 3. parameter is value which will be used if following element doesn't exist  
LEAD(OL.Quantity) OVER(PARTITION BY O.CustomerID         -- value after current offset    
					   ORDER BY O.OrderDate, O.OrderID) AS next_val
FROM Sales.OrderLines AS OL 
     join Sales.Orders AS O ON O.OrderID = OL.OrderID;

SELECT O.CustomerID, O.OrderID, O.OrderDate, OL.Quantity,
FIRST_VALUE(OL.Quantity) OVER(PARTITION BY O.CustomerID                      
							  ORDER BY O.OrderDate, O.OrderID    
							  ROWS BETWEEN UNBOUNDED PRECEDING      
							  AND CURRENT ROW) AS first_val,  
LAST_VALUE(OL.Quantity) OVER(PARTITION BY O.CustomerID              
							 ORDER BY O.OrderDate, O.OrderID         
							 ROWS BETWEEN CURRENT ROW             
							 AND UNBOUNDED FOLLOWING) AS last_val
FROM Sales.OrderLines AS OL 
     join Sales.Orders AS O ON O.OrderID = OL.OrderID;

SELECT * 
FROM Sales.OrderLines;