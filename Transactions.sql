SET XACT_ABORT ON;

BEGIN TRAN;
SELECT * 
FROM [Sales].[MyOrders];

INSERT INTO [Sales].[MyOrders]
VALUES(7, 8, 9, GETDATE());

SELECT * 
FROM [Sales].[MyOrders];

commit tran;