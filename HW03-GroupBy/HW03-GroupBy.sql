/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

--напишите здесь свое решение
select 
	year(invoices.InvoiceDate) as [year],
	month(invoices.InvoiceDate) as [month],
	avg(invLines.Quantity * invLines.UnitPrice) as avgPrice,
	sum(invLines.Quantity * invLines.UnitPrice) as TotalValue
from
	Sales.Invoices as invoices
	join Sales.InvoiceLines as invLines on invLines.InvoiceID = invoices.InvoiceID
group by year(invoices.InvoiceDate), month(invoices.InvoiceDate)
order by [year], [month] 

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

--напишите здесь свое решение
select 
	year(invoices.InvoiceDate) as [year],
	month(invoices.InvoiceDate) as [month],
	sum(invLines.ExtendedPrice) as TotalValue
from
	Sales.Invoices as invoices
	join Sales.InvoiceLines as invLines on invLines.InvoiceID = invoices.InvoiceID
group by year(invoices.InvoiceDate), month(invoices.InvoiceDate)
having sum(invLines.ExtendedPrice) > 4600000
order by [year], [month] 

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

--напишите здесь свое решение
select 
	year(invoices.InvoiceDate) as [year],
	month(invoices.InvoiceDate) as [month],
	invLines.[Description] as [Description],
	count(*) as [SumSales],
	min(invoices.InvoiceDate) as [FirstSale],
	sum(invLines.Quantity) as [Quantity]
from
	Sales.Invoices as invoices
	join Sales.InvoiceLines as invLines on invLines.InvoiceID = invoices.InvoiceID
group by year(invoices.InvoiceDate), month(invoices.InvoiceDate), invLines.[Description]
having sum(invLines.Quantity) < 50
order by [Year], [Month], [Description]

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
--2.2
select 
	[year],
	[month],
	iif([TotalValue] > 4600000, [TotalValue], 0) as [TotalValue]
from 
	(select 
		year(invoices.InvoiceDate) as [year],
		month(invoices.InvoiceDate) as [month],
		sum(invLines.ExtendedPrice) as [TotalValue]
	from
		Sales.Invoices as invoices
		join Sales.InvoiceLines as invLines on invLines.InvoiceID = invoices.InvoiceID
	group by year(invoices.InvoiceDate), month(invoices.InvoiceDate)
	) as Tmp
order by [year], [month]

--2.3
select 
	[Year],
	[Month],
	[Description],
	iif([Quantity] < 50, 0, [SumSales]) as [SumSales],
	iif([Quantity] < 50, null, [FirstSale]) as [FirstSale],
	iif([Quantity] < 50, 0, [Quantity]) as [Quantity]
from 
	(select 
		year(invoices.InvoiceDate) as [year],
		month(invoices.InvoiceDate) as [month],
		invLines.[Description] as [Description],
		count(*) as [SumSales],
		min(invoices.InvoiceDate) as [FirstSale],
		sum(invLines.Quantity) as [Quantity]
	from
		Sales.Invoices as invoices
		join Sales.InvoiceLines as invLines on invLines.InvoiceID = invoices.InvoiceID
	group by year(invoices.InvoiceDate), month(invoices.InvoiceDate), invLines.[Description]
	) as Tmp
order by [Year], [Month], [Description]