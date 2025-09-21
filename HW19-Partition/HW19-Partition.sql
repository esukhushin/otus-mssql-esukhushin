USE InsuranceDB

GO
ALTER DATABASE [InsuranceDB] ADD FILEGROUP [QuarterData]

GO
ALTER DATABASE [InsuranceDB] ADD FILE ( NAME = N'Quarter', FILENAME = N'F:\OTUS_MsSqlServer\DB\QuarterData.ndf' , SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [QuarterData]

GO
CREATE PARTITION FUNCTION [fnQuarterPaymentsPartition](datetime) 
AS 
	RANGE RIGHT FOR VALUES ('2025-01-01','2025-04-01','2025-08-01','2025-10-01');
GO

GO
CREATE PARTITION SCHEME [schemeQuarterPaymentsPartition] 
AS 
	PARTITION [fnQuarterPaymentsPartition] ALL TO ([QuarterData])
GO

GO
CREATE TABLE [InsuranceDB].[dbo].[PaymentsPartition](
	[CreatedOn] datetime NOT NULL,
	[PaymentID] uniqueidentifier NOT NULL,
	[Sum] decimal(17,2) NOT NULL,
	[PaymentDate] datetime NOT NULL,
	[ModifiedOn] datetime NOT NULL,
 CONSTRAINT [PK_PaymentsPartition] PRIMARY KEY CLUSTERED 
(
	[CreatedOn] ASC,
	[PaymentID] ASC
)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [schemeQuarterPaymentsPartition]([CreatedOn])
) ON [PRIMARY]

GO
INSERT INTO PaymentsPartition SELECT [CreatedOn],[PaymentID],[Sum],[PaymentDate],[ModifiedOn]  FROM Payments

GO
SELECT * FROM [PaymentsPartition]

SELECT * FROM [PaymentsPartition] WHERE ModifiedOn BETWEEN '2025-01-01' AND '2025-03-31'

SELECT * FROM [PaymentsPartition] WHERE Createdon BETWEEN '2025-01-01' AND '2025-03-31'