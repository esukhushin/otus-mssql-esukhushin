/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "07 - ������������ SQL".

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

��� ������� �� ������� "��������� CROSS APPLY, PIVOT, UNPIVOT."
����� ��� ���� �������� ������������ PIVOT, ������������ ���������� �� ���� ��������.
��� ������� ��������� ��������� �� ���� CustomerName.

��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.

���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.

������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (������ �������)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

--InputParameters
declare @CustomerIDs nvarchar(max) = N'2,3,4,5,6'



--Solution
IF OBJECT_ID('tempdb..#Tmp') IS NOT NULL 
	DROP TABLE #Tmp

create table #Tmp (id int)

if(len(@CustomerIDs) > 0)
	insert into #Tmp select cast(value as int) from STRING_SPLIT(@CustomerIDs, ',')
else
	insert into #Tmp select distinct CustomerId from Sales.Customers

declare 
	@customerNames nvarchar(max) = '', 
	@sqlCommand nvarchar(max) = '';

select @customerNames += '[' + CustomerName + '],' from Sales.Customers where CustomerID in (select * from #Tmp)
if(len(@customerNames) > 0)
	set @customerNames = SUBSTRING(@CustomerNames, 1, len(@CustomerNames) - 1)

set @sqlCommand = '
select 
	FORMAT([InvoiceMonthSub], ''dd.MM.yyyy'') as [InvoiceMonth],
	' + (select @customerNames) + '
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
				customersInner.CustomerName as [CustomerName],
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
		invoces.CustomerID in (select id from #Tmp)
) as sourceTable
pivot
(
	sum([Sum])
	for [CustomerName] in 
	(
		' + (select @customerNames) + '
	)
)
as pivotTable
order by [InvoiceMonthSub]';

EXECUTE sp_executesql @sqlCommand