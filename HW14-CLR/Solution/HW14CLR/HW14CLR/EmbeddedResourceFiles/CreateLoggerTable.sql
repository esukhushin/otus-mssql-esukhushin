IF NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'HW14Logger')
BEGIN
	CREATE TABLE [dbo].[HW14Logger](
		[ID] [uniqueidentifier] NOT NULL,
		[Surname] [nvarchar](max) NULL,
		[Name] [nvarchar](max) NULL,
		[Patronymic] [nvarchar](max) NULL,
		[Birthday] [date] NULL,
		[Phone] [nvarchar](max) NULL,
		[Address] [nvarchar](max) NULL,
		[InputXml] [xml] NULL,
		[IsSuccess] [bit] NULL,
	 CONSTRAINT [PK_HW14Logger] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [USERDATA]
	) ON [USERDATA] TEXTIMAGE_ON [USERDATA]

	ALTER TABLE [dbo].[HW14Logger] ADD  CONSTRAINT [DF_HW14Logger_ID]  DEFAULT (newid()) FOR [ID]
END