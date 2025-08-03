exec sp_configure 'show advanced options', 1;
GO
reconfigure;

-- ���������, �������� �� CLR
SELECT name, value_in_use  
FROM sys.configurations  
WHERE name = 'clr enabled';

-- �������� CLR (���� ��������)
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;

--��������� ������� ������������
SELECT name, value_in_use  
FROM sys.configurations  
WHERE name = 'clr strict security';

exec sp_configure 'clr strict security', 0 ;
RECONFIGURE;


-- ��� ����������� �������� ������ � EXTERNAL_ACCESS ��� UNSAFE
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON; 

GO
ALTER AUTHORIZATION ON DATABASE :: WideWorldImporters to [sa]

CREATE ASSEMBLY HW14CLR
FROM 'F:\OTUS_MsSqlServer\GithubRepository\esukhushin\otus-mssql-esukhushin\HW14-CLR\Solution\HW14CLR\HW14CLR\bin\Debug\HW14CLR.dll'
WITH PERMISSION_SET = UNSAFE;  

GO
CREATE PROCEDURE [dbo].[CreateLoggerTable] (@value nvarchar(max) out)
AS EXTERNAL NAME [HW14CLR].[HW14CLR.XmlValidation].[CreateLoggerTable];

GO
CREATE PROCEDURE [dbo].[DropLoggerTable] (@value nvarchar(max) out)
AS EXTERNAL NAME [HW14CLR].[HW14CLR.XmlValidation].[DropLoggerTable];

GO
CREATE PROCEDURE [dbo].[Validation] (@inputData nvarchar(max), @value nvarchar(max) out)
AS EXTERNAL NAME [HW14CLR].[HW14CLR.XmlValidation].[Validation];


GO
DECLARE	@return_value int,
		@value nvarchar(max)

EXEC	@return_value = [dbo].[CreateLoggerTable]
		@value = @value OUTPUT

SELECT	@value as N'@value'

GO -- Success
DECLARE	@return_value int,
		@value nvarchar(max)

EXEC	@return_value = [dbo].[Validation] @inputData = N'<?xml version="1.0" encoding="utf-8"?>
                <Root>
                    <User>
                        <Surname>������</Surname>
                        <Name>����</Name>
                        <Patronymic>��������</Patronymic>
                        <Birthday>1900-01-01</Birthday>
                        <Phone>+79847584562</Phone>
                        <Address>��. ������ 120</Address>
                    </User>
                    <User>
                        <Surname>������ 2</Surname>
                        <Name>���� 2</Name>
                        <Patronymic>�������� 2</Patronymic>
                        <Birthday>1901-01-01</Birthday>
                        <Phone>+79847584563</Phone>
                        <Address>��. ������ 125</Address>
                    </User>
                </Root>',
		@value = @value OUTPUT

SELECT	@value as N'@value'

GO --Validation Error
DECLARE	@return_value int,
		@value nvarchar(max)

EXEC	@return_value = [dbo].[Validation] @inputData = N'<?xml version="1.0" encoding="utf-8"?>
                <Root>
                    <User>
                        <Surname>������</Surname>
                        <Name>����</Name>
                        <Patronymic>��������</Patronymic>
                        <Birthday>1900-01-01</Birthday>
                        <Phone>+79847584562</Phone>
                        <Address>��. ������ 120</Address>
						<Address2>��. ������ 120</Address2>
                    </User>
                    <User>
                        <Surname>������ 2</Surname>
                        <Name>���� 2</Name>
                        <Patronymic>�������� 2</Patronymic>
                        <Birthday>1901-01-01</Birthday>
                        <Phone>+79847584563</Phone>
                        <Address>��. ������ 125</Address>
                    </User>
                </Root>',
		@value = @value OUTPUT

SELECT	@value as N'@value'

GO
SELECT * FROM [dbo].HW14Logger

GO
DECLARE	@return_value int,
		@value nvarchar(max)

EXEC	@return_value = [dbo].[DropLoggerTable]
		@value = @value OUTPUT

SELECT	@value as N'@value'