/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

--напишите здесь свое решение
select distinct
	inv.InvoiceID,
	customers.CustomerName,
	inv.InvoiceDate,
	[SalesSum] = (select sum(lines.Quantity * lines.UnitPrice) 
					from Sales.InvoiceLines as lines 
					where lines.InvoiceID = inv.InvoiceID),
	
	[SalesSumRunning] = (select sum(invLines2.Quantity * invLines2.UnitPrice) 
							from 
								Sales.Invoices as inv2 
								join Sales.InvoiceLines as invLines2 on invLines2.InvoiceID = inv2.InvoiceID
							where 
								(year(inv2.InvoiceDate) <= year(inv.InvoiceDate) and month(inv2.InvoiceDate) <= month(inv.InvoiceDate)) 
								and year(inv2.InvoiceDate) >= 2015)
	
from 
	Sales.Invoices as inv 
	join Sales.Customers as customers on customers.CustomerID = inv.CustomerID
where
	year(inv.InvoiceDate) >= 2015
order by 
	inv.InvoiceID, inv.InvoiceDate asc;


/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

--напишите здесь свое решение
select
	inv.InvoiceID,
	customers.CustomerName,
	inv.InvoiceDate,
	[SalesSum] = sum(invLines.Quantity * invLines.UnitPrice) over(partition by inv.InvoiceID),
	[SalesSumRunning] = sum(invLines.Quantity * invLines.UnitPrice) over(order by year(inv.InvoiceDate), month(inv.InvoiceDate) asc)
from 
	Sales.Invoices as inv
	join Sales.Customers as customers on customers.CustomerID = inv.CustomerID
	join Sales.InvoiceLines as invLines on invLines.InvoiceID = inv.InvoiceID
where
	year(inv.InvoiceDate) >= 2015
order by 
	inv.InvoiceID, inv.InvoiceDate asc;

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

--напишите здесь свое решение
with InvoiceLinesRank_cte
as
(
	select
		YEAR(inv.InvoiceDate) as [Year],
		MONTH(inv.InvoiceDate) as [Month],
		invLines.StockItemID,
		sum(invLines.Quantity) as [StockItemCount],
		ROW_NUMBER() over (partition by YEAR(inv.InvoiceDate), MONTH(inv.InvoiceDate) order by sum(invLines.Quantity) desc) as [StockItemRank]
	from
		Sales.Invoices as inv
		join Sales.InvoiceLines as invLines on invLines.InvoiceID = inv.InvoiceID
	where
		year(InvoiceDate) = 2016
	group by
		YEAR(inv.InvoiceDate),
		MONTH(inv.InvoiceDate),
		[StockItemID]
)
select 
	[Year],
	[Month],
	si.StockItemName
from 
	InvoiceLinesRank_cte as ilr
	join Warehouse.StockItems as si on si.StockItemID = ilr.StockItemID
where
	[StockItemRank] <= 2
order by
	[YEAR],
	[Month],
	ilr.StockItemRank;

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
(1)* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
(2)* посчитайте общее количество товаров и выведете полем в этом же запросе
(3)* посчитайте общее количество товаров в зависимости от первой буквы названия товара
(4)* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
(5)* предыдущий ид товара с тем же порядком отображения (по имени)
(6)* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
(7)* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

--напишите здесь свое решение
select
	items.StockItemID
	,items.StockItemName
	,items.Brand
	,items.UnitPrice
	,row_number() over (partition by items.StockItemName order by items.StockItemName asc) as [(1)]
	,row_number() over (order by items.StockItemName) as [(2)]
	,count(*) over (partition by SUBSTRING(items.StockItemName, 1, 1) order by items.StockItemName asc) as [(3)]
	,lead(items.StockItemID, 1) over (order by items.StockItemName asc) as [(4)]
	,lag(items.StockItemID, 1) over (order by items.StockItemName asc) as [(5)]
	,lag(items.StockItemName, 2, 'No items') over (order by items.StockItemName asc) as [(6)]
	,ntile(30) over (partition by items.TypicalWeightPerUnit order by items.StockItemName asc) as [(7)]
from
	Warehouse.StockItems as items
order by
	items.StockItemName asc;

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

--напишите здесь свое решение
with InvoiceLinesRank_cte
as
(
	select
		inv.SalespersonPersonID,
		inv.CustomerID,
		inv.InvoiceDate as [InvoiceDateMax],
		sum(invLines.Quantity * invLines.UnitPrice) as [Price],
		ROW_NUMBER() over (partition by inv.SalespersonPersonID order by max(inv.InvoiceDate) desc) as [InvoiceDateRank]
	from
		Sales.Invoices as inv
		join Sales.InvoiceLines as invLines on invLines.InvoiceID = inv.InvoiceID
	group by
		inv.SalespersonPersonID,
		inv.CustomerID,
		inv.InvoiceDate
)
select
	ilr.SalespersonPersonID,
	people.FullName,
	ilr.CustomerID,
	customers.CustomerName,
	ilr.InvoiceDateMax,
	ilr.Price
from
	InvoiceLinesRank_cte as ilr
	join Application.People as people on people.PersonID = ilr.SalespersonPersonID
	join Sales.Customers as customers on customers.CustomerID = ilr.CustomerID
where
	ilr.InvoiceDateRank = 1
order by
	ilr.SalespersonPersonID asc;

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

--напишите здесь свое решение
with InvoiceLinesRank_cte
as
(
	select
		inv.CustomerID,
		invLines.StockItemID,
		max(invLines.UnitPrice) as [StockItemMaxPrice],
		max(inv.InvoiceDate) as [InvoiceDate],
		rank() over (partition by inv.CustomerID order by max(invLines.UnitPrice) desc) as [StockItemRank]
	from
		Sales.Invoices as inv
		join Sales.InvoiceLines as invLines on invLines.InvoiceID = inv.InvoiceID
	group by
		inv.CustomerID,
		invLines.StockItemID
)
select 
	customer.CustomerID,
	customer.CustomerName,
	ilr.StockItemID,
	ilr.StockItemMaxPrice,
	ilr.InvoiceDate
from 
	InvoiceLinesRank_cte as ilr
	join Sales.Customers as customer on customer.CustomerID =ilr.CustomerID
where
	ilr.StockItemRank <= 2
order by
	customer.CustomerID;

--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 
