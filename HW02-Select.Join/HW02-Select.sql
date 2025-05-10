/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

--напишите здесь свое решение
select 
	StockItemID, 
	StockItemName 
from 
	Warehouse.StockItems as items 
where 
	items.StockItemName like 'Animal%' or items.StockItemName like '%urgent%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

--напишите здесь свое решение
select 
	suppiers.SupplierID,
	suppiers.SupplierName
from 
	Purchasing.Suppliers as suppiers left join Purchasing.PurchaseOrders as orders
		on suppiers.SupplierID = orders.SupplierID
where
	orders.PurchaseOrderID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

--напишите здесь свое решение
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
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

--напишите здесь свое решение
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
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

--напишите здесь свое решение
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
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

--напишите здесь свое решение
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