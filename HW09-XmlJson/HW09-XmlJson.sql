/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

--напишите здесь свое решение
declare @Tmp table
(
	[StockItemID] int,
	[StockItemName] nvarchar(100),
	[SupplierID] int,
	[UnitPackageID] int,
	[OuterPackageID] int,
	[QuantityPerOuter] int,
	[TypicalWeightPerUnit] decimal,
	[LeadTimeDays] int,
	[IsChillerStock] bit,
	[TaxRate] decimal,
	[UnitPrice] decimal,
	[LastEditedBy] int default(1)
)

declare @xmlDocument xml;
select 
	@xmlDocument = BulkColumn
from 
	openrowset(bulk 'F:\OTUS_MsSqlServer\TempFiles\StockItems.xml', single_clob) as t

------------------------------------------------------------------------------------------------
insert into @Tmp
(
	[StockItemName],
	[SupplierID],
	[UnitPackageID],
	[OuterPackageID],
	[QuantityPerOuter],
	[TypicalWeightPerUnit],
	[LeadTimeDays],
	[IsChillerStock],
	[TaxRate],
	[UnitPrice]
)
select 
	[StockItemName] = d.item.value('(@Name)[1]', 'nvarchar(100)'),
	[SupplierID] = d.item.value('(SupplierID)[1]', 'int'),
	[UnitPackageID] = d.item.value('(Package/UnitPackageID)[1]', 'int'),
	[OuterPackageID] = d.item.value('(Package/OuterPackageID)[1]', 'int'),
	[QuantityPerOuter] = d.item.value('(Package/QuantityPerOuter)[1]', 'int'),
	[TypicalWeightPerUnit] = d.item.value('(Package/TypicalWeightPerUnit)[1]', 'decimal'),
	[LeadTimeDays] = d.item.value('(LeadTimeDays)[1]', 'int'),
	[IsChillerStock] = d.item.value('(IsChillerStock)[1]', 'bit'),
	[TaxRate] = d.item.value('(TaxRate)[1]', 'decimal'),
	[UnitPrice] = d.item.value('(UnitPrice)[1]', 'decimal')
from
	@xmlDocument.nodes('/StockItems/Item') AS d(item)

------------------------------------------------------------------------------------------------
declare @docHandle int;
exec sp_xml_preparedocument @docHandle output, @xmlDocument;
------------------------------------------------------------------------------------------------

insert into @Tmp
(
	[StockItemName],
	[SupplierID],
	[UnitPackageID],
	[OuterPackageID],
	[QuantityPerOuter],
	[TypicalWeightPerUnit],
	[LeadTimeDays],
	[IsChillerStock],
	[TaxRate],
	[UnitPrice]
)
select *
from openxml(@docHandle, N'/StockItems/Item') --путь к строкам
with 
( 
	[StockItemName] nvarchar(100)  '@Name', -- атрибут
	[SupplierID] int 'SupplierID',
	[UnitPackageID] int 'Package/UnitPackageID',
	[OuterPackageID] int 'Package/OuterPackageID',
	[QuantityPerOuter] int 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] decimal 'Package/TypicalWeightPerUnit',
	[LeadTimeDays] int 'LeadTimeDays',
	[IsChillerStock] bit 'IsChillerStock',
	[TaxRate] decimal 'TaxRate',
	[UnitPrice] decimal 'UnitPrice'
)

------------------------------------------------------------------------------------------------
declare @LastID int
select top 1 @LastID = [StockItemID] from Warehouse.StockItems order by [StockItemID] desc
update @Tmp set @LastID = @LastID + 1, StockItemID = @LastID;
------------------------------------------------------------------------------------------------

merge Warehouse.StockItems as [target] 
using @Tmp as [source]
	on [target].[StockItemName] = [source].[StockItemName]
when matched
	then update 
			set 
				[SupplierID] = [source].[SupplierID],
				[UnitPackageID] = [source].[UnitPackageID],
				[OuterPackageID] = [source].[OuterPackageID],
				[QuantityPerOuter] = [source].[QuantityPerOuter],
				[TypicalWeightPerUnit] = [source].[TypicalWeightPerUnit],
				[LeadTimeDays] = [source].[LeadTimeDays],
				[IsChillerStock] = [source].[IsChillerStock],
				[TaxRate] = [source].[TaxRate],
				[UnitPrice] = [source].[UnitPrice]
when not matched
	then insert
		(
			[StockItemID],
			[StockItemName],
			[SupplierID],
			[UnitPackageID],
			[OuterPackageID],
			[QuantityPerOuter],
			[TypicalWeightPerUnit],
			[LeadTimeDays],
			[IsChillerStock],
			[TaxRate],
			[UnitPrice],
			[LastEditedBy]
		) 
		values 
		(
			[source].[StockItemID],
			[source].[StockItemName],
			[source].[SupplierID],
			[source].[UnitPackageID],
			[source].[OuterPackageID],
			[source].[QuantityPerOuter],
			[source].[TypicalWeightPerUnit],
			[source].[LeadTimeDays],
			[source].[IsChillerStock],
			[source].[TaxRate],
			[source].[UnitPrice],
			[source].[LastEditedBy]
		)
output deleted.*, $action, inserted.*;

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

--напишите здесь свое решение
select
	items.StockItemName as '@Name',
	items.SupplierID,
	items.UnitPackageID as [Package/UnitPackageID],
	items.OuterPackageID as [Package/OuterPackageID],
	items.QuantityPerOuter as [Package/QuantityPerOuter],
	items.TypicalWeightPerUnit as [Package/TypicalWeightPerUnit],
	items.LeadTimeDays as [LeadTimeDays],
	items.IsChillerStock as [IsChillerStock],
	items.TaxRate as [TaxRate],
	items.UnitPrice as [UnitPrice]
from 
	Warehouse.StockItems as items
for xml path('Item'), root('StockItems');


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

--напишите здесь свое решение
select 
	items.StockItemID,
	items.StockItemName,
	CountryOfManufacture,
	FirstTag
from 
	Warehouse.StockItems as items
outer apply 
openjson(items.CustomFields)
with
(
	CountryOfManufacture nvarchar(100) '$.CountryOfManufacture',
	FirstTag nvarchar(50) '$.Tags[0]'
);

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/


--напишите здесь свое решение
select 
	items.StockItemID,
	items.StockItemName,
	tags.value
from 
	Warehouse.StockItems as items
outer apply 
openjson(items.CustomFields, '$.Tags') as tags
where tags.value = 'Vintage';