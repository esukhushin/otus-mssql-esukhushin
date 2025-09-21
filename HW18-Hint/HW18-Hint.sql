DECLARE @StartTime DATETIME2 = SYSUTCDATETIME();

Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Sales.Orders AS ord
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans
        ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

DECLARE @EndTime DATETIME2 = SYSUTCDATETIME();
DECLARE @ExecutionTimeMs INT = DATEDIFF(MILLISECOND, @StartTime, @EndTime);

SELECT 
    @ExecutionTimeMs AS ExecutionTimeMs,
    @ExecutionTimeMs / 1000.0 AS ExecutionTimeSeconds,
    @ExecutionTimeMs / 1000.0 / 60.0 AS ExecutionTimeMinutes;
--------------------------------------------
GO

--Часть запроса перенёс во временную таблицу, добавил кластерный индекс для временной таблицы, результат: оригинал - 520 мс, результат - 342 мс

DECLARE @StartTime DATETIME2 = SYSUTCDATETIME();

IF OBJECT_ID('tempdb..#TmpTable') IS NOT NULL 
	DROP TABLE #TmpTable

SELECT 
	o.CustomerID,
	SUM(ol.UnitPrice*ol.Quantity) as [Sum]
INTO #TmpTable
FROM 
	Sales.Orders AS o
	join Sales.OrderLines AS ol
		ON ol.OrderID = o.OrderID
GROUP BY 
	o.CustomerID

CREATE CLUSTERED INDEX IX_TmpTable_CustomerID ON #TmpTable (CustomerID)

Select 
	ord.CustomerID, 
	det.StockItemID, 
	SUM(det.UnitPrice), 
	SUM(det.Quantity), 
	COUNT(ord.OrderID)
FROM Sales.Orders AS ord 
	JOIN #TmpTable
		ON #TmpTable.CustomerID = ord.CustomerID
    JOIN Sales.OrderLines AS det 
		ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv
		ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans
		ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans
		ON ItemTrans.StockItemID = det.StockItemID
	JOIN Warehouse.StockItems as StockItems 
		ON StockItems.StockItemID = det.StockItemID
WHERE 
	Inv.BillToCustomerID != ord.CustomerID
    AND StockItems.SupplierId = 12
	and #TmpTable.[Sum] > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

DECLARE @EndTime DATETIME2 = SYSUTCDATETIME();
DECLARE @ExecutionTimeMs INT = DATEDIFF(MILLISECOND, @StartTime, @EndTime);

SELECT 
    @ExecutionTimeMs AS ExecutionTimeMs,
    @ExecutionTimeMs / 1000.0 AS ExecutionTimeSeconds,
    @ExecutionTimeMs / 1000.0 / 60.0 AS ExecutionTimeMinutes;

