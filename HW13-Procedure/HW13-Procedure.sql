/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/
GO
CREATE or ALTER FUNCTION GetCustomerMaxBuy()
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP 1
		customer.CustomerName,
		sum(invLines.Quantity * invLines.UnitPrice) as [Price]
	FROM 
		Sales.InvoiceLines as invLines
		join Sales.Invoices as inv on inv.InvoiceID = invLines.InvoiceID
		join Sales.Customers as customer on customer.CustomerID = inv.CustomerID
	GROUP BY
		customer.CustomerName,
		inv.InvoiceID
	ORDER BY
		sum(invLines.Quantity * invLines.UnitPrice) desc
);
GO
SELECT * FROM GetCustomerMaxBuy();
GO
DROP FUNCTION [dbo].[GetCustomerMaxBuy];

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/
GO
CREATE or ALTER PROCEDURE GetCustomerSumByCustomerId @CustomerId INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED; --можно позиционировать как сводку данных, поэтому используем только зафиксированные данные

	SELECT
		customer.CustomerName,
		sum(invLines.Quantity * invLines.UnitPrice) as [TotalPrice]
	FROM 
		Sales.InvoiceLines as invLines
		join Sales.Invoices as inv on inv.InvoiceID = invLines.InvoiceID
		join Sales.Customers as customer on customer.CustomerID = inv.CustomerID
	WHERE
		customer.CustomerID = @CustomerId
	GROUP BY
		customer.CustomerName
END;
GO
EXEC GetCustomerSumByCustomerId 3;
GO
DROP PROCEDURE [dbo].[GetCustomerSumByCustomerId];
/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/
GO
CREATE or ALTER FUNCTION TestFunction1(@max INT)
RETURNS BIGINT
AS
BEGIN
	DECLARE @output bigint = 1;
	DECLARE @current int = 1;
	WHILE @current < @max
	BEGIN
		SET @current = @current + 1;
		SET @output = @output + @current;	
	END
	RETURN @output;
END;
GO
CREATE or ALTER PROCEDURE TestProcedure1(@max int, @output bigint output)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; -- т.к. функционал не имеет отношение к БД

	SET @output = 1;
	DECLARE @current int = 1;
	WHILE @current < @max
	BEGIN
		SET @current = @current + 1;
		SET @output = @output + @current;	
	END
END;
GO

PRINT convert(nvarchar(max), GetDate(), 121)

DECLARE @i int = 0;
WHILE @i <= 10
BEGIN
	DECLARE @result bigint
	SET @result =  [dbo].[TestFunction1](1000000);
	SET @i = @i + 1;
END

PRINT convert(nvarchar(max), GetDate(), 121) 

GO
PRINT convert(nvarchar(max), GetDate(), 121) 

DECLARE @i int = 0;
WHILE @i <= 10
BEGIN
	DECLARE @output bigint, @max int = 1000000;
	EXEC TestProcedure1 @max, @output output;
	SET @i = @i + 1;
END

PRINT convert(nvarchar(max), GetDate(), 121) 

GO
DROP FUNCTION [dbo].[TestFunction1];
DROP PROCEDURE [dbo].[TestProcedure1]

--Простая функция работает быстрее процедуры, возможно вследствие меньших издержек при вызове

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/
CREATE or ALTER FUNCTION GetCustomerByID(@customerId int)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		DeliveryAddressLine1,
		DeliveryAddressLine2,
		PostalAddressLine1,
		PostalAddressLine2
	FROM 
		Sales.Customers as customers
	WHERE
		customers.CustomerID = @customerId
);
GO
SELECT 
	customers.CustomerName,
	CustomerNames.*
FROM 
	Sales.Customers as customers 
	cross apply GetCustomerByID(customers.CustomerID) as CustomerNames
GO
DROP FUNCTION [dbo].[GetCustomerByID];



/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
