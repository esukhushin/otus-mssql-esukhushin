DROP DATABASE IF EXISTS [InsuranceDB];

CREATE DATABASE [InsuranceDB]
	CONTAINMENT = NONE
	ON  PRIMARY 
( 
	NAME = N'InsuranceDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\InsuranceDB.mdf', 
	SIZE = 8192KB, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB 
)
LOG ON 
( 
	NAME = N'InsuranceDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\InsuranceDB_log.ldf', 
	SIZE = 73728KB, 
	MAXSIZE = 2048GB, 
	FILEGROWTH = 65536KB 
)
WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF

GO
CREATE TABLE [InsuranceDB].[dbo].[Discounts](
	[DiscountID] uniqueidentifier NOT NULL,
	[Sum] money NOT NULL,
	[Ñause] nvarchar(250) NULL,
	[CreatedOn] datetime NOT NULL,
 CONSTRAINT [PK_Discounts] PRIMARY KEY CLUSTERED 
(
	[DiscountID] ASC
)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDB].[dbo].[Discounts] ADD  CONSTRAINT [DF_Discounts_DiscountID]  DEFAULT (newid()) FOR [DiscountID]

GO
CREATE TABLE [InsuranceDB].[dbo].[Payments](
	[PaymentID] uniqueidentifier NOT NULL,
	[Sum] money NOT NULL,
	[CreatedOn] datetime NOT NULL,
 CONSTRAINT [PK_Payments] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDB].[dbo].[Payments] ADD  CONSTRAINT [DF_Payments_PaymentID]  DEFAULT (newid()) FOR [PaymentID]

GO
CREATE TABLE [InsuranceDB].[dbo].[ContractsTemplate](
	[ContractTemplateID] uniqueidentifier NOT NULL,
	[Name] nvarchar(250) NOT NULL,
	[DefaultPrice] money NOT NULL,
	[CreatedOn] datetime NOT NULL,
 CONSTRAINT [PK_ContractsTemplate] PRIMARY KEY CLUSTERED 
(
	[ContractTemplateID] ASC
)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDB].[dbo].[ContractsTemplate] ADD  CONSTRAINT [DF_ContractsTemplate_ContractTemplateID]  DEFAULT (newid()) FOR [ContractTemplateID]

GO
CREATE TABLE [InsuranceDB].[dbo].[Companies](
	[CompanyID] uniqueidentifier NOT NULL,
	[ShortName] nvarchar(50) NOT NULL,
	[LongName] nvarchar(200) NOT NULL,
	[CreatedOn] datetime NOT NULL,
 CONSTRAINT [PK_Companies] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC
)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDB].[dbo].[Companies] ADD  CONSTRAINT [DF_Companies_CompanyID]  DEFAULT (newid()) FOR [CompanyID]

GO
CREATE TABLE [InsuranceDB].[dbo].[PersonsStatus](
	[PersonStatusID] uniqueidentifier NOT NULL,
	[PersonStatusName] nvarchar(50) NOT NULL,
	[CreatedOn] datetime NOT NULL,
 CONSTRAINT [PK_PersonsStatus] PRIMARY KEY CLUSTERED 
(
	[PersonStatusID] ASC
)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDB].[dbo].[PersonsStatus] ADD  CONSTRAINT [DF_PersonsStatus_PersonStatusID]  DEFAULT (newid()) FOR [PersonStatusID]

GO
CREATE TABLE [InsuranceDB].[dbo].[Persons](
	[PersonID] uniqueidentifier NOT NULL,
	[PersonStatusID] uniqueidentifier NULL,
	[Surname] nvarchar(100) NOT NULL,
	[Name] nvarchar(100) NOT NULL,
	[Patronymic] nvarchar(100) NULL,
	[Birthday] date NOT NULL,
	[PassportSeries] nvarchar(10) NOT NULL,
	[PassportNumber] nvarchar(10) NOT NULL,
	[CreatedOn] datetime NOT NULL,
 CONSTRAINT [PK_Persons] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDB].[dbo].[Persons] ADD  CONSTRAINT [DF_Persons_PersonID]  DEFAULT (newid()) FOR [PersonID]
GO
ALTER TABLE [InsuranceDB].[dbo].[Persons]  WITH CHECK ADD  CONSTRAINT [FK_Persons_PersonsStatus] FOREIGN KEY([PersonStatusID])
REFERENCES [InsuranceDB].[dbo].[PersonsStatus] ([PersonStatusID])
ON UPDATE SET NULL
ON DELETE SET NULL
GO
ALTER TABLE [InsuranceDB].[dbo].[Persons] CHECK CONSTRAINT [FK_Persons_PersonsStatus]

GO
CREATE TABLE [InsuranceDB].[dbo].[Employees](
	[CompanyID] uniqueidentifier NOT NULL,
	[PersonID] uniqueidentifier NOT NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[PersonID] ASC
)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDB].[dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Companies] FOREIGN KEY([CompanyID])
REFERENCES [InsuranceDB].[dbo].[Companies] ([CompanyID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDB].[dbo].[Employees] CHECK CONSTRAINT [FK_Employees_Companies]
GO
ALTER TABLE [InsuranceDB].[dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Persons] FOREIGN KEY([PersonID])
REFERENCES [InsuranceDB].[dbo].[Persons] ([PersonID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDB].[dbo].[Employees] CHECK CONSTRAINT [FK_Employees_Persons]

GO
CREATE TABLE [InsuranceDB].[dbo].[Contracts](
	[ContractID] uniqueidentifier NOT NULL,
	[ContractTemplateID] uniqueidentifier NULL,
	[CompanyID] uniqueidentifier NULL,
	[ManagerID] uniqueidentifier NULL,
	[ClientID] uniqueidentifier NULL,
	[ContractBegin] datetime NOT NULL,
	[ContractEnd] datetime NOT NULL,
	[Price] money NOT NULL,
	[CreatedOn] datetime NOT NULL,
 CONSTRAINT [PK_Contracts] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC
)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDB].[dbo].[Contracts] ADD  CONSTRAINT [DF_Contracts_ContractID]  DEFAULT (newid()) FOR [ContractID]
GO
ALTER TABLE [InsuranceDB].[dbo].[Contracts]  WITH CHECK ADD  CONSTRAINT [FK_Contracts_Companies] FOREIGN KEY([CompanyID])
REFERENCES [InsuranceDB].[dbo].[Companies] ([CompanyID])
ON UPDATE SET NULL
ON DELETE SET NULL
GO
ALTER TABLE [InsuranceDB].[dbo].[Contracts] CHECK CONSTRAINT [FK_Contracts_Companies]
GO
ALTER TABLE [InsuranceDB].[dbo].[Contracts]  WITH CHECK ADD  CONSTRAINT [FK_Contracts_ContractsTemplate] FOREIGN KEY([ContractTemplateID])
REFERENCES [InsuranceDB].[dbo].[ContractsTemplate] ([ContractTemplateID])
ON UPDATE SET NULL
ON DELETE SET NULL
GO
ALTER TABLE [InsuranceDB].[dbo].[Contracts] CHECK CONSTRAINT [FK_Contracts_ContractsTemplate]
GO
ALTER TABLE [InsuranceDB].[dbo].[Contracts]  WITH CHECK ADD  CONSTRAINT [FK_Contracts_Persons_Client] FOREIGN KEY([ClientID])
REFERENCES [InsuranceDB].[dbo].[Persons] ([PersonID])
GO
ALTER TABLE [InsuranceDB].[dbo].[Contracts] CHECK CONSTRAINT [FK_Contracts_Persons_Client]
GO
ALTER TABLE [InsuranceDB].[dbo].[Contracts]  WITH CHECK ADD  CONSTRAINT [FK_Contracts_Persons_Manager] FOREIGN KEY([ManagerID])
REFERENCES [InsuranceDB].[dbo].[Persons] ([PersonID])
GO
ALTER TABLE [InsuranceDB].[dbo].[Contracts] CHECK CONSTRAINT [FK_Contracts_Persons_Manager]

GO
CREATE TABLE [InsuranceDB].[dbo].[ContractsDiscounts](
	[ContractID] uniqueidentifier NOT NULL,
	[DiscountID] uniqueidentifier NOT NULL,
 CONSTRAINT [PK_ContractsDiscounts] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC,
	[DiscountID] ASC
)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDB].[dbo].[ContractsDiscounts]  WITH CHECK ADD  CONSTRAINT [FK_ContractsDiscounts_Contracts] FOREIGN KEY([ContractID])
REFERENCES [InsuranceDB].[dbo].[Contracts] ([ContractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDB].[dbo].[ContractsDiscounts] CHECK CONSTRAINT [FK_ContractsDiscounts_Contracts]
GO
ALTER TABLE [InsuranceDB].[dbo].[ContractsDiscounts]  WITH CHECK ADD  CONSTRAINT [FK_ContractsDiscounts_Discounts] FOREIGN KEY([DiscountID])
REFERENCES [InsuranceDB].[dbo].[Discounts] ([DiscountID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDB].[dbo].[ContractsDiscounts] CHECK CONSTRAINT [FK_ContractsDiscounts_Discounts]

GO
CREATE TABLE [InsuranceDB].[dbo].[ContractsPayments](
	[ContractID] uniqueidentifier NOT NULL,
	[PaymentID] uniqueidentifier NOT NULL,
 CONSTRAINT [PK_ContractsPayments] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC,
	[PaymentID] ASC
)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDB].[dbo].[ContractsPayments]  WITH CHECK ADD  CONSTRAINT [FK_ContractsPayments_Contracts] FOREIGN KEY([ContractID])
REFERENCES [InsuranceDB].[dbo].[Contracts] ([ContractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDB].[dbo].[ContractsPayments] CHECK CONSTRAINT [FK_ContractsPayments_Contracts]
GO
ALTER TABLE [InsuranceDB].[dbo].[ContractsPayments]  WITH CHECK ADD  CONSTRAINT [FK_ContractsPayments_Payments] FOREIGN KEY([PaymentID])
REFERENCES [InsuranceDB].[dbo].[Payments] ([PaymentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDB].[dbo].[ContractsPayments] CHECK CONSTRAINT [FK_ContractsPayments_Payments]