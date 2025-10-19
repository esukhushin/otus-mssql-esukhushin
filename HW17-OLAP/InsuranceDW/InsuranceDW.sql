DROP DATABASE IF EXISTS [InsuranceDW];

CREATE DATABASE [InsuranceDW]
	CONTAINMENT = NONE
	ON  PRIMARY 
( 
	NAME = N'InsuranceDW', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\InsuranceDW.mdf', 
	SIZE = 8192KB, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB 
)
LOG ON 
( 
	NAME = N'InsuranceDW_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\InsuranceDW_log.ldf', 
	SIZE = 73728KB, 
	MAXSIZE = 2048GB, 
	FILEGROWTH = 65536KB 
)
WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF

GO
CREATE TABLE [InsuranceDW].[dbo].[Companies](
	[CompanyID] [uniqueidentifier] NOT NULL,
	[ShortName] [nvarchar](50) NOT NULL,
	[LongName] [nvarchar](200) NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ModifiedOn] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Companies] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDW].[dbo].[Companies] ADD  CONSTRAINT [DF_Companies_CompanyID]  DEFAULT (newid()) FOR [CompanyID]

GO
CREATE TABLE [InsuranceDW].[dbo].[PersonsStatus](
	[PersonStatusID] [uniqueidentifier] NOT NULL,
	[PersonStatusName] [nvarchar](50) NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ModifiedOn] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_PersonsStatus] PRIMARY KEY CLUSTERED 
(
	[PersonStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDW].[dbo].[PersonsStatus] ADD  CONSTRAINT [DF_PersonsStatus_PersonStatusID]  DEFAULT (newid()) FOR [PersonStatusID]

GO
CREATE TABLE [InsuranceDW].[dbo].[ContractsTemplate](
	[ContractTemplateID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[DefaultPrice] [decimal](18, 2) NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ModifiedOn] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_ContractsTemplate] PRIMARY KEY CLUSTERED 
(
	[ContractTemplateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDW].[dbo].[ContractsTemplate] ADD  CONSTRAINT [DF_ContractsTemplate_ContractTemplateID]  DEFAULT (newid()) FOR [ContractTemplateID]

GO
CREATE TABLE [InsuranceDW].[dbo].[DimDate](
	[DateId] [uniqueidentifier] NOT NULL,
	[FullDate] [datetime2](7) NOT NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Day] [int] NOT NULL,
 CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED 
(
	[DateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDW].[dbo].[DimDate] ADD  CONSTRAINT [DF_DimDate_DateId]  DEFAULT (newid()) FOR [DateId]

GO
CREATE TABLE [InsuranceDW].[dbo].[Persons](
	[PersonID] [uniqueidentifier] NOT NULL,
	[PersonStatusID] [uniqueidentifier] NOT NULL,
	[Surname] [nvarchar](100) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Patronymic] [nvarchar](100) NULL,
	[Birthday] [datetime2](7) NOT NULL,
	[PassportSeries] [nvarchar](10) NOT NULL,
	[PassportNumber] [nvarchar](10) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Persons] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDW].[dbo].[Persons] ADD  CONSTRAINT [DF_Persons_PersonID]  DEFAULT (newid()) FOR [PersonID]
GO
ALTER TABLE [InsuranceDW].[dbo].[Persons]  WITH CHECK ADD  CONSTRAINT [FK_Persons_PersonsStatus] FOREIGN KEY([PersonStatusID])
REFERENCES [InsuranceDW].[dbo].[PersonsStatus] ([PersonStatusID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDW].[dbo].[Persons] CHECK CONSTRAINT [FK_Persons_PersonsStatus]

GO
CREATE TABLE [InsuranceDW].[dbo].[Employees](
	[CompanyID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDW].[dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Companies] FOREIGN KEY([CompanyID])
REFERENCES [InsuranceDW].[dbo].[Companies] ([CompanyID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDW].[dbo].[Employees] CHECK CONSTRAINT [FK_Employees_Companies]
GO
ALTER TABLE [InsuranceDW].[dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Persons] FOREIGN KEY([PersonID])
REFERENCES [InsuranceDW].[dbo].[Persons] ([PersonID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDW].[dbo].[Employees] CHECK CONSTRAINT [FK_Employees_Persons]

GO
CREATE TABLE [InsuranceDW].[dbo].[Contracts](
	[ContractId] [uniqueidentifier] NOT NULL,
	[DateId] [uniqueidentifier] NOT NULL,
	[ContractTemplateID] [uniqueidentifier] NOT NULL,
	[CompanyID] [uniqueidentifier] NOT NULL,
	[ManagerID] [uniqueidentifier] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[ContractBegin] [datetime2](7) NOT NULL,
	[ContractEnd] [datetime2](7) NOT NULL,
	[Price] [decimal](18, 2) NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ModifiedOn] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Contracts] PRIMARY KEY CLUSTERED 
(
	[ContractId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDW].[dbo].[Contracts] ADD  CONSTRAINT [DF_Contracts_ContractId]  DEFAULT (newid()) FOR [ContractId]
GO
ALTER TABLE [InsuranceDW].[dbo].[Contracts]  WITH CHECK ADD  CONSTRAINT [FK_Contracts_Companies] FOREIGN KEY([CompanyID])
REFERENCES [InsuranceDW].[dbo].[Companies] ([CompanyID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDW].[dbo].[Contracts] CHECK CONSTRAINT [FK_Contracts_Companies]
GO
ALTER TABLE [InsuranceDW].[dbo].[Contracts]  WITH CHECK ADD  CONSTRAINT [FK_Contracts_ContractsTemplate] FOREIGN KEY([ContractTemplateID])
REFERENCES [InsuranceDW].[dbo].[ContractsTemplate] ([ContractTemplateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDW].[dbo].[Contracts] CHECK CONSTRAINT [FK_Contracts_ContractsTemplate]
GO
ALTER TABLE [InsuranceDW].[dbo].[Contracts]  WITH CHECK ADD  CONSTRAINT [FK_Contracts_DimDate] FOREIGN KEY([DateId])
REFERENCES [InsuranceDW].[dbo].[DimDate] ([DateId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDW].[dbo].[Contracts] CHECK CONSTRAINT [FK_Contracts_DimDate]
GO
ALTER TABLE [InsuranceDW].[dbo].[Contracts]  WITH CHECK ADD  CONSTRAINT [FK_Contracts_Persons] FOREIGN KEY([ManagerID])
REFERENCES [InsuranceDW].[dbo].[Persons] ([PersonID])
GO
ALTER TABLE [InsuranceDW].[dbo].[Contracts] CHECK CONSTRAINT [FK_Contracts_Persons]
GO
ALTER TABLE [InsuranceDW].[dbo].[Contracts]  WITH CHECK ADD  CONSTRAINT [FK_Contracts_Persons1] FOREIGN KEY([ClientID])
REFERENCES [InsuranceDW].[dbo].[Persons] ([PersonID])
GO
ALTER TABLE [InsuranceDW].[dbo].[Contracts] CHECK CONSTRAINT [FK_Contracts_Persons1]

GO
CREATE TABLE [InsuranceDW].[dbo].[Discounts](
	[DiscountID] [uniqueidentifier] NOT NULL,
	[ContractID] [uniqueidentifier] NOT NULL,
	[Sum] [decimal](18, 2) NOT NULL,
	[Сause] [nvarchar](250) NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ModifiedOn] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Discounts_1] PRIMARY KEY CLUSTERED 
(
	[DiscountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDW].[dbo].[Discounts] ADD  CONSTRAINT [DF_Discounts_DiscountID]  DEFAULT (newid()) FOR [DiscountID]
GO
ALTER TABLE [InsuranceDW].[dbo].[Discounts]  WITH CHECK ADD  CONSTRAINT [FK_Discounts_Contracts] FOREIGN KEY([ContractID])
REFERENCES [InsuranceDW].[dbo].[Contracts] ([ContractId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDW].[dbo].[Discounts] CHECK CONSTRAINT [FK_Discounts_Contracts]

GO
CREATE TABLE [InsuranceDW].[dbo].[Payments](
	[PaymentID] [uniqueidentifier] NOT NULL,
	[ContractID] [uniqueidentifier] NOT NULL,
	[Sum] [decimal](18, 2) NOT NULL,
	[PaymentDate] [datetime2](7) NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ModifiedOn] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Payments_1] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InsuranceDW].[dbo].[Payments] ADD  CONSTRAINT [DF_Payments_ContractsTemplate]  DEFAULT (newid()) FOR [PaymentID]
GO
ALTER TABLE [InsuranceDW].[dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Payments_Contracts] FOREIGN KEY([ContractID])
REFERENCES [InsuranceDW].[dbo].[Contracts] ([ContractId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [InsuranceDW].[dbo].[Payments] CHECK CONSTRAINT [FK_Payments_Contracts]