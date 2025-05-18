/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, GROUP BY, HAVING".

������� ����������� � �������������� ���� ������ WideWorldImporters.

����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak

�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. ��������� ������� ���� ������, ����� ����� ������� �� �������.
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ������� ���� �� ����� �� ���� �������
* ����� ����� ������ �� �����

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

--�������� ����� ���� �������
select 
	year(orders.OrderDate) as [year],
	month(orders.OrderDate) as [month],
	avg(invLines.ExtendedPrice) as avgPrice,
	sum(invLines.ExtendedPrice) as TotalValue
from
	Sales.Orders as orders
	join Sales.Invoices as invoices on invoices.OrderID = orders.OrderID
	join Sales.InvoiceLines as invLines on invLines.InvoiceID = invoices.InvoiceID
group by year(orders.OrderDate), month(orders.OrderDate)
order by [year], [month] 

/*
2. ���������� ��� ������, ��� ����� ����� ������ ��������� 4 600 000

�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ����� ����� ������

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

--�������� ����� ���� �������
select 
	year(orders.OrderDate) as [year],
	month(orders.OrderDate) as [month],
	sum(invLines.ExtendedPrice) as TotalValue
from
	Sales.Orders as orders
	join Sales.Invoices as invoices on invoices.OrderID = orders.OrderID
	join Sales.InvoiceLines as invLines on invLines.InvoiceID = invoices.InvoiceID
group by year(orders.OrderDate), month(orders.OrderDate)
having sum(invLines.ExtendedPrice) > 4600000
order by [year], [month] 

/*
3. ������� ����� ������, ���� ������ �������
� ���������� ���������� �� �������, �� �������,
������� ������� ����� 50 �� � �����.
����������� ������ ���� �� ����,  ������, ������.

�������:
* ��� �������
* ����� �������
* ������������ ������
* ����� ������
* ���� ������ �������
* ���������� ����������

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

--�������� ����� ���� �������
select 
	year(orders.OrderDate) as [Year],
	month(orders.OrderDate) as [Month],
	invLines.[Description] as [Description],
	count(*) as [SumSales],
	min(invoices.InvoiceDate) as [FirstSale],
	sum(invLines.Quantity) as [Quantity]
from
	Sales.Orders as orders
	join Sales.Invoices as invoices on invoices.OrderID = orders.OrderID
	join Sales.InvoiceLines as invLines on invLines.InvoiceID = invoices.InvoiceID
group by year(orders.OrderDate), month(orders.OrderDate), invLines.[Description]
having sum(invLines.Quantity) < 50
order by [Year], [Month], [Description]

-- ---------------------------------------------------------------------------
-- �����������
-- ---------------------------------------------------------------------------
/*
�������� ������� 2-3 ���, ����� ���� � �����-�� ������ �� ���� ������,
�� ���� ����� ����� ����������� �� � �����������, �� ��� ���� ����.
*/
--2.2
select 
	[year],
	[month],
	iif([TotalValue] > 4600000, [TotalValue], 0) as [TotalValue]
from 
	(select 
		year(orders.OrderDate) as [year],
		month(orders.OrderDate) as [month],
		sum(invLines.ExtendedPrice) as [TotalValue]
	from
		Sales.Orders as orders
		join Sales.Invoices as invoices on invoices.OrderID = orders.OrderID
		join Sales.InvoiceLines as invLines on invLines.InvoiceID = invoices.InvoiceID
	group by year(orders.OrderDate), month(orders.OrderDate)
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
		year(orders.OrderDate) as [Year],
		month(orders.OrderDate) as [Month],
		invLines.[Description] as [Description],
		count(*) as [SumSales],
		min(invoices.InvoiceDate) as [FirstSale],
		sum(invLines.Quantity) as [Quantity]
	from
		Sales.Orders as orders
		join Sales.Invoices as invoices on invoices.OrderID = orders.OrderID
		join Sales.InvoiceLines as invLines on invLines.InvoiceID = invoices.InvoiceID
	group by year(orders.OrderDate), month(orders.OrderDate), invLines.[Description]
	) as Tmp
order by [Year], [Month], [Description]