USE InsuranceDB
GO

INSERT INTO PersonsStatus (PersonStatusName,CreatedOn,ModifiedOn) 
VALUES(N'Клиент', GETDATE(), GETDATE());
INSERT INTO PersonsStatus (PersonStatusName,CreatedOn,ModifiedOn) 
VALUES(N'VIP Клиент', GETDATE(), GETDATE());
INSERT INTO PersonsStatus (PersonStatusName,CreatedOn,ModifiedOn) 
VALUES(N'Сотрудник', GETDATE(), GETDATE());

GO

INSERT INTO Companies (ShortName, LongName, CreatedOn, ModifiedOn)
VALUES (N'OOO СОГАЗ', N'OOO СОГАЗ', GETDATE(), GETDATE());

GO

INSERT INTO ContractsTemplate (Name, DefaultPrice, CreatedOn, ModifiedOn)
VALUES (N'Базовый тариф', 5000, GETDATE(), GETDATE());
INSERT INTO ContractsTemplate (Name, DefaultPrice, CreatedOn, ModifiedOn)
VALUES (N'VIP тариф', 15000, GETDATE(), GETDATE());

GO

INSERT INTO Persons (PersonStatusID, Surname, Name, Patronymic, Birthday, PassportSeries, PassportNumber, CreatedOn, ModifiedOn)
VALUES 
(
	(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'Сотрудник'),
	N'Иванов',
	N'Иван',
	N'Иванович',
	'1990-05-13',
	'0001',
	'123754',
	GETDATE(), 
	GETDATE()
);
INSERT INTO Persons (PersonStatusID, Surname, Name, Patronymic, Birthday, PassportSeries, PassportNumber, CreatedOn, ModifiedOn)
VALUES 
(
	(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'Клиент'),
	N'Петров',
	N'Петр',
	N'Петрович',
	'1980-03-20',
	'0002',
	'765157',
	GETDATE(), 
	GETDATE()
);
INSERT INTO Persons (PersonStatusID, Surname, Name, Patronymic, Birthday, PassportSeries, PassportNumber, CreatedOn, ModifiedOn)
VALUES 
(
	(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'VIP Клиент'),
	N'Сидоров',
	N'Андрей',
	N'Николаевич',
	'1984-11-07',
	'0003',
	'483169',
	GETDATE(), 
	GETDATE()
);

GO

INSERT INTO Employees VALUES
(
	(select top 1 CompanyID from Companies),
	(select top 1 PersonID from Persons where Surname = N'Иванов')
);

GO

DECLARE @ContractIDBase uniqueidentifier = newID(),
	@ContractIDVip uniqueidentifier = newID();

DELETE FROM Contracts

INSERT INTO Contracts 
(
	ContractID,
	ContractTemplateID, 
	CompanyID, 
	ManagerID, 
	ClientID, 
	ContractBegin, 
	ContractEnd, 
	Price, 
	CreatedOn, 
	ModifiedOn
)
VALUES
(
	@ContractIDBase,
	(select top 1 ContractTemplateID from ContractsTemplate where Name = N'Базовый тариф'),
	(select top 1 CompanyID from Companies),
	(select top 1 PersonID from Persons where PersonStatusID = 
		(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'Сотрудник')),
	(select top 1 PersonID from Persons where PersonStatusID = 
		(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'Клиент')),
	'2025-01-01',
	'2025-12-31',
	5000,
	GETDATE(), 
	GETDATE()
);
INSERT INTO Contracts 
(
	ContractID,
	ContractTemplateID, 
	CompanyID, 
	ManagerID, 
	ClientID, 
	ContractBegin, 
	ContractEnd, 
	Price, 
	CreatedOn, 
	ModifiedOn
)
VALUES
(
	@ContractIDVip,
	(select top 1 ContractTemplateID from ContractsTemplate where Name = N'VIP тариф'),
	(select top 1 CompanyID from Companies),
	(select top 1 PersonID from Persons where PersonStatusID = 
		(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'Сотрудник')),
	(select top 1 PersonID from Persons where PersonStatusID = 
		(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'VIP Клиент')),
	'2025-01-01',
	'2025-12-31',
	15000,
	GETDATE(), 
	GETDATE()
);

DECLARE @PaymentIDBase uniqueidentifier = newID(), 
		@DiscountIDBase uniqueidentifier = newID(),
		@PaymentIDVip uniqueidentifier = newID(), 
		@DiscountIDVip uniqueidentifier = newID();
	
DELETE FROM Payments 
DELETE FROM Discounts

INSERT INTO Payments (PaymentID, Sum, PaymentDate, CreatedOn, ModifiedOn)
VALUES (@PaymentIDBase, 1000, '2025-02-12', GETDATE(), GETDATE());
INSERT INTO Payments (PaymentID, Sum, PaymentDate, CreatedOn, ModifiedOn)
VALUES (@PaymentIDVip, 3000, '2025-12-12', GETDATE(), GETDATE());

INSERT INTO ContractsPayments VALUES (@ContractIDBase, @PaymentIDBase);
INSERT INTO ContractsPayments VALUES (@ContractIDVip, @PaymentIDVip);

INSERT INTO Discounts (DiscountID, Sum, Сause, CreatedOn, ModifiedOn)
VALUES (@DiscountIDBase, 1000, N'Скидка базовая', GETDATE(), GETDATE());
INSERT INTO Discounts (DiscountID, Sum, Сause, CreatedOn, ModifiedOn)
VALUES (@DiscountIDVip, 2000, N'Скидка VIP', GETDATE(), GETDATE());

INSERT INTO ContractsDiscounts VALUES (@ContractIDBase, @DiscountIDBase);
INSERT INTO ContractsDiscounts VALUES (@ContractIDVip, @DiscountIDVip);