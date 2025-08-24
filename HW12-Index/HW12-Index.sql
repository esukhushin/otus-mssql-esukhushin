USE InsuranceDB

DROP INDEX IF EXISTS IX_Persons_Surname ON [InsuranceDB].[dbo].[Persons]
DROP INDEX IF EXISTS IX_Contracts_ContractBegin ON [InsuranceDB].[dbo].[Contracts]
DROP INDEX IF EXISTS IX_Contracts_ContractEnd ON [InsuranceDB].[dbo].[Contracts]

GO

CREATE NONCLUSTERED INDEX [IX_Persons_Surname] ON [InsuranceDB].[dbo].[Persons]
(
	[Surname] ASC,
	[Name] ASC
)
INCLUDE([PersonID],[Patronymic],[Birthday],[PassportSeries],[PassportNumber])

GO

CREATE NONCLUSTERED INDEX [IX_Contracts_ContractBegin] ON [InsuranceDB].[dbo].[Contracts]
(
	[ContractBegin] ASC
)
INCLUDE([ContractID])

GO

CREATE NONCLUSTERED INDEX [IX_Contracts_ContractEnd] ON [InsuranceDB].[dbo].[Contracts]
(
	[ContractEnd] ASC
)
INCLUDE([ContractID])