/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

--TODO: напишите здесь свое решение
select 
	people.PersonID,
	people.FullName
from Application.People as people 
where 
	people.IsSalesperson = 1
	and people.PersonID not in 
		(select 
			inv.SalespersonPersonID
		from Sales.Invoices as inv 
		where inv.InvoiceDate = '2015-07-04');


with inv_cte
as
(
	select 
		inv.SalespersonPersonID
	from Sales.Invoices as inv 
	where inv.InvoiceDate = '2015-07-04'
)
select 
	people.PersonID,
	people.FullName
from Application.People as people 
where 
	people.IsSalesperson = 1
	and people.PersonID not in ( select * from inv_cte);
/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

--TODO: напишите здесь свое решение
select
	items.StockItemID,
	items.StockItemName,
	items.UnitPrice
from
	Warehouse.StockItems as items
where items.UnitPrice = (select min(UnitPrice) from Warehouse.StockItems);

select
	items.StockItemID,
	items.StockItemName,
	items.UnitPrice
from
	Warehouse.StockItems as items
where items.UnitPrice = (select top 1 UnitPrice from Warehouse.StockItems as items2 order by items2.UnitPrice asc);

with minPrice_cte
as
(
	select min(UnitPrice) as [minPrice] from Warehouse.StockItems
)
select 
	items.StockItemID,
	items.StockItemName,
	items.UnitPrice
from
	Warehouse.StockItems as items
where items.UnitPrice = (select * from minPrice_cte);


/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

--TODO: напишите здесь свое решение
select
	*
from 
	Sales.Customers as customer
where
	customer.CustomerID in 
	(
		select 
			top 5  trans.CustomerID 
		from 
			Sales.CustomerTransactions as trans 
		order by 
			trans.TransactionAmount desc
	);

with trans_cte
as
(
	select 
		top 5 trans.CustomerID 
	from 
		Sales.CustomerTransactions as trans 
	order by 
		trans.TransactionAmount desc
)
select
	*
from 
	Sales.Customers as customer
where
	customer.CustomerID in (select * from trans_cte);

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

--TODO: напишите здесь свое решение
select 
	distinct
	cities.CityID,
	cities.CityName,
	people.FullName as [People]
from
	Application.Cities as cities
	join Sales.Customers as customers on customers.PostalCityID = cities.CityID
	join Sales.Invoices as inv on inv.CustomerID = customers.CustomerID
	join Application.People as people on people.PersonID = inv.PackedByPersonID
	join Sales.InvoiceLines as invLines on invLines.InvoiceID = inv.InvoiceID
where
		invLines.StockItemID in 
			(select top 3 items.StockItemID from Warehouse.StockItems as items order by items.UnitPrice desc);

with topItems_cte
as
(
	select top 3 items.StockItemID from Warehouse.StockItems as items order by items.UnitPrice desc
)
select 
	distinct
	cities.CityID,
	cities.CityName,
	people.FullName as [People]
from
	Application.Cities as cities
	join Sales.Customers as customers on customers.PostalCityID = cities.CityID
	join Sales.Invoices as inv on inv.CustomerID = customers.CustomerID
	join Application.People as people on people.PersonID = inv.PackedByPersonID
	join Sales.InvoiceLines as invLines on invLines.InvoiceID = inv.InvoiceID
where 
	invLines.StockItemID in (select * from topItems_cte);

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC;

--TODO: напишите здесь свое решение
-- основное снижение стоимости запроса за счёт табличной переменной для подзапроса в блоке "FROM",
-- временная таблица позволяет избежать многократного запуска "тяжёлого" подзапроса
-- сравнение стоимости (96% против 4%)

declare @Tmp table (InvoiceId int, TotalSumm decimal(17,2))

INSERT into @Tmp
SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000

SELECT 
	inv.InvoiceID, 
	inv.InvoiceDate,
	People.FullName AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = inv.OrderId)	
	) AS TotalSummForPickedItems
FROM 
	Sales.Invoices as inv
	JOIN @Tmp AS SalesTotals ON inv.InvoiceID = SalesTotals.InvoiceID
	JOIN Application.People as people on people.PersonID = inv.SalespersonPersonID
ORDER BY TotalSumm DESC;
