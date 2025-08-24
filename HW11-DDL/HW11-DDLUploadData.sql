USE InsuranceDB
GO

INSERT INTO PersonsStatus (PersonStatusName,CreatedOn,ModifiedOn) 
VALUES(N'������', GETDATE(), GETDATE());
INSERT INTO PersonsStatus (PersonStatusName,CreatedOn,ModifiedOn) 
VALUES(N'VIP ������', GETDATE(), GETDATE());
INSERT INTO PersonsStatus (PersonStatusName,CreatedOn,ModifiedOn) 
VALUES(N'���������', GETDATE(), GETDATE());

GO

INSERT INTO Companies (ShortName, LongName, CreatedOn, ModifiedOn)
VALUES (N'OOO �����', N'OOO �����', GETDATE(), GETDATE());

GO

INSERT INTO ContractsTemplate (Name, DefaultPrice, CreatedOn, ModifiedOn)
VALUES (N'������� �����', 5000, GETDATE(), GETDATE());
INSERT INTO ContractsTemplate (Name, DefaultPrice, CreatedOn, ModifiedOn)
VALUES (N'VIP �����', 15000, GETDATE(), GETDATE());

GO

INSERT INTO Persons (PersonStatusID, Surname, Name, Patronymic, Birthday, PassportSeries, PassportNumber, CreatedOn, ModifiedOn)
VALUES 
(
	(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'���������'),
	N'������',
	N'����',
	N'��������',
	'1990-05-13',
	'0001',
	'123754',
	GETDATE(), 
	GETDATE()
);
INSERT INTO Persons (PersonStatusID, Surname, Name, Patronymic, Birthday, PassportSeries, PassportNumber, CreatedOn, ModifiedOn)
VALUES 
(
	(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'������'),
	N'������',
	N'����',
	N'��������',
	'1980-03-20',
	'0002',
	'765157',
	GETDATE(), 
	GETDATE()
);
INSERT INTO Persons (PersonStatusID, Surname, Name, Patronymic, Birthday, PassportSeries, PassportNumber, CreatedOn, ModifiedOn)
VALUES 
(
	(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'VIP ������'),
	N'�������',
	N'������',
	N'����������',
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
	(select top 1 PersonID from Persons where Surname = N'������')
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
	(select top 1 ContractTemplateID from ContractsTemplate where Name = N'������� �����'),
	(select top 1 CompanyID from Companies),
	(select top 1 PersonID from Persons where PersonStatusID = 
		(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'���������')),
	(select top 1 PersonID from Persons where PersonStatusID = 
		(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'������')),
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
	(select top 1 ContractTemplateID from ContractsTemplate where Name = N'VIP �����'),
	(select top 1 CompanyID from Companies),
	(select top 1 PersonID from Persons where PersonStatusID = 
		(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'���������')),
	(select top 1 PersonID from Persons where PersonStatusID = 
		(select top 1 PersonStatusID from PersonsStatus where PersonStatusName = N'VIP ������')),
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

INSERT INTO Discounts (DiscountID, Sum, �ause, CreatedOn, ModifiedOn)
VALUES (@DiscountIDBase, 1000, N'������ �������', GETDATE(), GETDATE());
INSERT INTO Discounts (DiscountID, Sum, �ause, CreatedOn, ModifiedOn)
VALUES (@DiscountIDVip, 2000, N'������ VIP', GETDATE(), GETDATE());

INSERT INTO ContractsDiscounts VALUES (@ContractIDBase, @DiscountIDBase);
INSERT INTO ContractsDiscounts VALUES (@ContractIDVip, @DiscountIDVip);