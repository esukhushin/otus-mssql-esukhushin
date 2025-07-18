/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

--напишите здесь свое решение
select 
	FORMAT([InvoiceMonthSub], 'dd.MM.yyyy') as [InvoiceMonth],
	pivotTable.[Peeples Valley, AZ],
	pivotTable.[Medicine Lodge, KS],
	pivotTable.[Gasport, NY],
	pivotTable.[Sylvanite, MT],
	pivotTable.[Jessie, ND]
from
(
	select distinct
		DATEFROMPARTS(year(invoces.InvoiceDate), month(invoces.InvoiceDate), 1) as [InvoiceMonthSub],
		CustomerNames.*
	from  
		Sales.Invoices as invoces
		cross apply
		(
			select
				substring(customersInner.CustomerName, 
				charindex('(', customersInner.CustomerName) + 1, 
				charindex(')', customersInner.CustomerName) - charindex('(', customersInner.CustomerName) - 1) as [CustomerName],
				count(*) as [Sum] 
			from
				Sales.Customers as customersInner
				join Sales.Invoices as invocesInner on invocesInner.CustomerID = customersInner.CustomerID
			where
				invocesInner.CustomerID = invoces.CustomerID
				and year(invocesInner.InvoiceDate) = year(invoces.InvoiceDate)
				and month(invocesInner.InvoiceDate) = month(invoces.InvoiceDate)
			group by
				customersInner.CustomerName
		) CustomerNames ([CustomerName], [Sum])
	where
		invoces.CustomerID between 2 and 6
) as sourceTable
pivot
(
	sum([Sum])
	for [CustomerName] in 
	(
		[Gasport, NY],
		[Jessie, ND],
		[Medicine Lodge, KS],
		[Peeples Valley, AZ],
		[Sylvanite, MT]
	)
)
as pivotTable
order by [InvoiceMonthSub]


/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

--напишите здесь свое решение
select 
	CustomerName,
	AddressLine
from
(
	select 
		customers.CustomerName,
		CustomerNames.*
	from 
		Sales.Customers as customers 
		cross apply
		(
			select 
				DeliveryAddressLine1,
				DeliveryAddressLine2,
				PostalAddressLine1,
				PostalAddressLine2
			from 
				Sales.Customers as customersInner
			where
				customers.CustomerID = customersInner.CustomerID
		) CustomerNames (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2)
) as SourceTable
unpivot
(
	AddressLine for SourceTable in (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2)
) as result


/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

--напишите здесь свое решение
select 
	CountryID,
	CountryName,
	Code
from
(
	select 
		CountryID,
		CountryName,
		Country.*
	from 
		Application.Countries as countries 
		cross apply
		(
			select 
				cast(IsoAlpha3Code as nvarchar(3)) as [IsoAlpha3Code], 
				cast(IsoNumericCode as nvarchar(3)) as [IsoNumericCode]
			from 
				Application.Countries as countiesInner
			where
				countries.CountryID = countiesInner.CountryID
		) Country (IsoAlpha3Code, IsoNumericCode)
) as SourceTable
unpivot
(
	Code for SourceTable in (IsoAlpha3Code, IsoNumericCode)
) as result

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
select 
	customer.CustomerID,
	customer.CustomerName,
	SourceTable.*
from 
	Sales.Customers as customer
	cross apply
	(
		select 
			[StockItemID], 
			[StockItemMaxPrice],
			[InvoiceDate] 
		from
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
			) as SubTable ([CustomerID], [StockItemID], [StockItemMaxPrice], [InvoiceDate], [StockItemRank])
		where 
			SubTable.CustomerID = customer.CustomerID 
			and SubTable.[StockItemRank] <= 2
	) as SourceTable (StockItemID, StockItemMaxPrice, InvoiceDate);