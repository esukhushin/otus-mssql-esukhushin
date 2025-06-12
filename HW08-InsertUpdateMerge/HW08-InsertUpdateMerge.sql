/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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

--select * into Sales.CustomersCopy from Sales.Customers
--select * from Sales.CustomersCopy

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

--напишите здесь свое решение
declare @CustomerID int
      ,@CustomerName nvarchar(100)
      ,@BillToCustomerID int
      ,@CustomerCategoryID int
      ,@PrimaryContactPersonID int
      ,@DeliveryMethodID int
      ,@DeliveryCityID int
      ,@PostalCityID int
      ,@AccountOpenedDate date
      ,@StandardDiscountPercentage decimal(18,3)
      ,@IsStatementSent bit
      ,@IsOnCreditHold bit
      ,@PaymentDays int
      ,@PhoneNumber nvarchar(20)
      ,@FaxNumber nvarchar(20)
      ,@WebsiteURL nvarchar(256)
      ,@DeliveryAddressLine1 nvarchar(60)
      ,@DeliveryPostalCode nvarchar(10)
      ,@PostalAddressLine1 nvarchar(60)
      ,@PostalPostalCode nvarchar(10)
      ,@LastEditedBy int
      ,@ValidFrom datetime2(7)
      ,@ValidTo datetime2(7)

select top 1
	   @CustomerID  = c.CustomerID
	  ,@CustomerName = ''
	  ,@BillToCustomerID = c.BillToCustomerID
      ,@CustomerCategoryID  = c.CustomerCategoryID
      ,@PrimaryContactPersonID = c.PrimaryContactPersonID
      ,@DeliveryMethodID = c.DeliveryMethodID
      ,@DeliveryCityID = c.DeliveryCityID
      ,@PostalCityID = c.PostalCityID
      ,@AccountOpenedDate = c.AccountOpenedDate
      ,@StandardDiscountPercentage = c.StandardDiscountPercentage
      ,@IsStatementSent = c.IsStatementSent
      ,@IsOnCreditHold = c.IsOnCreditHold
      ,@PaymentDays = c.PaymentDays
      ,@PhoneNumber = c.PhoneNumber
      ,@FaxNumber = c.FaxNumber
      ,@WebsiteURL = c.WebsiteURL
      ,@DeliveryAddressLine1 = c.DeliveryAddressLine1
      ,@DeliveryPostalCode = c.DeliveryPostalCode
      ,@PostalAddressLine1 = c.PostalAddressLine1
      ,@PostalPostalCode = c.PostalPostalCode
      ,@LastEditedBy = c.LastEditedBy
from Sales.Customers as c order by c.CustomerID desc

insert into Sales.Customers 
	(CustomerID,CustomerName,BillToCustomerID,CustomerCategoryID,PrimaryContactPersonID,DeliveryMethodID,DeliveryCityID,PostalCityID,AccountOpenedDate,StandardDiscountPercentage
      ,IsStatementSent,IsOnCreditHold,PaymentDays,PhoneNumber,FaxNumber,WebsiteURL,DeliveryAddressLine1,DeliveryPostalCode,PostalAddressLine1,PostalPostalCode,LastEditedBy)
values
	(@CustomerID + 1,N'Иванов',@BillToCustomerID,@CustomerCategoryID,@PrimaryContactPersonID,@DeliveryMethodID,@DeliveryCityID ,@PostalCityID 
      ,@AccountOpenedDate,@StandardDiscountPercentage,@IsStatementSent,@IsOnCreditHold,@PaymentDays,@PhoneNumber,@FaxNumber,@WebsiteURL,@DeliveryAddressLine1
      ,@DeliveryPostalCode,@PostalAddressLine1,@PostalPostalCode,@LastEditedBy)
	,(@CustomerID + 2,N'Петров',@BillToCustomerID,@CustomerCategoryID,@PrimaryContactPersonID,@DeliveryMethodID,@DeliveryCityID ,@PostalCityID 
      ,@AccountOpenedDate,@StandardDiscountPercentage,@IsStatementSent,@IsOnCreditHold,@PaymentDays,@PhoneNumber,@FaxNumber,@WebsiteURL,@DeliveryAddressLine1
      ,@DeliveryPostalCode,@PostalAddressLine1,@PostalPostalCode,@LastEditedBy)
	,(@CustomerID + 3,N'Сидоров',@BillToCustomerID,@CustomerCategoryID,@PrimaryContactPersonID,@DeliveryMethodID,@DeliveryCityID ,@PostalCityID 
      ,@AccountOpenedDate,@StandardDiscountPercentage,@IsStatementSent,@IsOnCreditHold,@PaymentDays,@PhoneNumber,@FaxNumber,@WebsiteURL,@DeliveryAddressLine1
      ,@DeliveryPostalCode,@PostalAddressLine1,@PostalPostalCode,@LastEditedBy)
	,(@CustomerID + 4,N'Васильев',@BillToCustomerID,@CustomerCategoryID,@PrimaryContactPersonID,@DeliveryMethodID,@DeliveryCityID ,@PostalCityID 
      ,@AccountOpenedDate,@StandardDiscountPercentage,@IsStatementSent,@IsOnCreditHold,@PaymentDays,@PhoneNumber,@FaxNumber,@WebsiteURL,@DeliveryAddressLine1
      ,@DeliveryPostalCode,@PostalAddressLine1,@PostalPostalCode,@LastEditedBy)
	,(@CustomerID + 5,N'Кузнецов',@BillToCustomerID,@CustomerCategoryID,@PrimaryContactPersonID,@DeliveryMethodID,@DeliveryCityID ,@PostalCityID 
      ,@AccountOpenedDate,@StandardDiscountPercentage,@IsStatementSent,@IsOnCreditHold,@PaymentDays,@PhoneNumber,@FaxNumber,@WebsiteURL,@DeliveryAddressLine1
      ,@DeliveryPostalCode,@PostalAddressLine1,@PostalPostalCode,@LastEditedBy);

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

--напишите здесь свое решение
delete from Sales.Customers where CustomerID = 1062


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

--напишите здесь свое решение
update Sales.Customers set CustomerName = CustomerName + ' 1' where CustomerID = 1063

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

--напишите здесь свое решение
MERGE Sales.CustomersCopy as [target] 
USING Sales.Customers as [source]
	ON [target].CustomerID = [source].CustomerID
WHEN MATCHED
	THEN update 
			set 
				CustomerName = [source].CustomerName,
				BillToCustomerID = [source].BillToCustomerID,
				CustomerCategoryID = [source].CustomerCategoryID,
				PrimaryContactPersonID = [source].PrimaryContactPersonID,
				DeliveryMethodID = [source].DeliveryMethodID,
				DeliveryCityID = [source].DeliveryCityID,
				PostalCityID = [source].PostalCityID,
				AccountOpenedDate = [source].AccountOpenedDate,
				StandardDiscountPercentage = [source].StandardDiscountPercentage,
				IsStatementSent = [source].IsStatementSent,
				IsOnCreditHold = [source].IsOnCreditHold,
				PaymentDays = [source].PaymentDays,
				PhoneNumber = [source].PhoneNumber,
				FaxNumber = [source].FaxNumber,
				WebsiteURL = [source].WebsiteURL,
				DeliveryAddressLine1 = [source].DeliveryAddressLine1,
				DeliveryPostalCode = [source].DeliveryPostalCode,
				PostalAddressLine1 = [source].PostalAddressLine1,
				PostalPostalCode = [source].PostalPostalCode,
				LastEditedBy = [source].LastEditedBy
WHEN NOT MATCHED
	THEN insert
		(
			CustomerID,
			CustomerName,
			BillToCustomerID,
			CustomerCategoryID,
			PrimaryContactPersonID,
			DeliveryMethodID,
			DeliveryCityID,
			PostalCityID,
			AccountOpenedDate,
			StandardDiscountPercentage,
			IsStatementSent,
			IsOnCreditHold,
			PaymentDays,
			PhoneNumber,
			FaxNumber,
			WebsiteURL,
			DeliveryAddressLine1,
			DeliveryPostalCode,
			PostalAddressLine1,
			PostalPostalCode,
			LastEditedBy,
			ValidFrom,
			ValidTo
		) 
		VALUES 
		(
			[source].CustomerID,
			[source].CustomerName,
			[source].BillToCustomerID,
			[source].CustomerCategoryID,
			[source].PrimaryContactPersonID,
			[source].DeliveryMethodID,
			[source].DeliveryCityID,
			[source].PostalCityID,
			[source].AccountOpenedDate,
			[source].StandardDiscountPercentage,
			[source].IsStatementSent,
			[source].IsOnCreditHold,
			[source].PaymentDays,
			[source].PhoneNumber,
			[source].FaxNumber,
			[source].WebsiteURL,
			[source].DeliveryAddressLine1,
			[source].DeliveryPostalCode,
			[source].PostalAddressLine1,
			[source].PostalPostalCode,
			[source].LastEditedBy,
			[source].ValidFrom,
			[source].ValidTo
		)
WHEN NOT MATCHED BY SOURCE
	THEN DELETE
OUTPUT deleted.*, $action, inserted.*;


/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

--напишите здесь свое решение
EXEC master..xp_cmdshell 'bcp WideWorldImporters.Sales.CustomersCopy OUT "F:\OTUS_MsSqlServer\TempFiles\CustomersCopy.csv" -T -c -S DESKTOP-PO8V419'

select 
	* 
into Sales.CustomersCopy2 
from Sales.CustomersCopy as c
where c.CustomerID = -1

exec master..xp_cmdshell 'bcp WideWorldImporters.Sales.CustomersCopy2 IN "F:\OTUS_MsSqlServer\TempFiles\CustomersCopy.csv" -T -c -S DESKTOP-PO8V419'

truncate table Sales.CustomersCopy2

BULK INSERT Sales.CustomersCopy2 FROM 'F:\OTUS_MsSqlServer\TempFiles\CustomersCopy.csv';