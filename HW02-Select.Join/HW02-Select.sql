/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, JOIN".

������� ����������� � �������������� ���� ������ WideWorldImporters.

����� �� WideWorldImporters ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".
�������: �� ������ (StockItemID), ������������ ������ (StockItemName).
�������: Warehouse.StockItems.
*/

--�������� ����� ���� �������
select 
	StockItemID, 
	StockItemName 
from 
	Warehouse.StockItems as items 
where 
	items.StockItemName like 'Animal%' or items.StockItemName like '%urgent%'

/*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
������� ����� JOIN, � ����������� ������� ������� �� �����.
�������: �� ���������� (SupplierID), ������������ ���������� (SupplierName).
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
�� ����� �������� ������ JOIN ��������� ��������������.
*/

--�������� ����� ���� �������
select 
	suppiers.SupplierID,
	suppiers.SupplierName
from 
	Purchasing.Suppliers as suppiers left join Purchasing.PurchaseOrders as orders
		on suppiers.SupplierID = orders.SupplierID
where
	orders.PurchaseOrderID is null

/*
3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).
�������:
* OrderID
* ���� ������ (OrderDate) � ������� ��.��.����
* �������� ������, � ������� ��� ������ �����
* ����� ��������, � ������� ��� ������ �����
* ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������,
��������� ������ 1000 � ��������� ��������� 100 �������.

���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).

�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

--�������� ����� ���� �������
select 
	distinct
	orders.OrderID,
	format(orders.OrderDate, 'd', 'ru-ru') as 'OrderDate',
	format(orders.OrderDate, 'MMMM', 'ru-ru') as 'Month',
	datename(quarter, orders.OrderDate) as 'Quarter',
	'ThirdPart' = case
		when month(orders.OrderDate) between 1 and 4 then 1
		when month(orders.OrderDate) between 5 and 8 then 2
		else 3
	end,
	customers.CustomerName
from 
	Sales.Customers as customers 
	join Sales.Orders as orders on customers.CustomerID = orders.CustomerID
	join Sales.OrderLines as lines on orders.OrderID = lines.OrderID
where 
	(lines.UnitPrice > 100 or lines.Quantity > 20) and lines.PickingCompletedWhen is not null
order by 'Quarter','ThirdPart','OrderDate' asc
offset 1000 rows
fetch next 100 rows only

/*
4. ������ ����������� (Purchasing.Suppliers),
������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).
�������:
* ������ �������� (DeliveryMethodName)
* ���� �������� (ExpectedDeliveryDate)
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)

�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

--�������� ����� ���� �������
select 
	distinct
	DeliveryMethodName,
	ExpectedDeliveryDate,
	peopleSuppliers.FullName as peopleSuppliers,
	peopleOrders.FullName as peopleOrders
from
	Application.DeliveryMethods as methods
	join Purchasing.PurchaseOrders as orders on orders.DeliveryMethodID = methods.DeliveryMethodID
	join Purchasing.Suppliers as suppliers on suppliers.SupplierID = orders.SupplierID
	join Application.People as peopleOrders on peopleOrders.PersonID = orders.ContactPersonID
	join Application.People as peopleSuppliers on peopleSuppliers.PersonID = suppliers.PrimaryContactPersonID
where
	orders.ExpectedDeliveryDate between '2013-01-01' and '2013-01-31'
	and
	methods.DeliveryMethodName in ('Air Freight','Refrigerated Air Freight')

/*
5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������,
������� ������� ����� (SalespersonPerson).
������� ��� �����������.
*/

--�������� ����� ���� �������
select top 10
	customers.CustomerName,
	salesPerson.FullName as salesPerson
from 
	Sales.Orders as orders
	join Application.People as salesPerson on salesPerson.PersonID = orders.SalespersonPersonID
	join Sales.Customers as customers on customers.CustomerID = orders.CustomerID
order by 
	orders.OrderDate desc

/*
6. ��� �� � ����� �������� � �� ���������� ��������,
������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems.
*/

--�������� ����� ���� �������
select
	distinct
	customers.CustomerID,
	customers.CustomerName,
	customers.PhoneNumber
from
	Warehouse.StockItems as items
	join Application.People as person on person.PersonID = items.LastEditedBy
	join Sales.Customers as customers on customers.LastEditedBy = person.PersonID
where
	items.StockItemName = 'Chocolate frogs 250g'