USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER  WITH ROLLBACK IMMEDIATE; --NO WAIT --prod (в однопользовательском режиме!!! На проде так не нужно)

ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];

--Включите это чтобы доверять сервисам без использования сертификатов когда работаем между различными 
--БД и инстансами(фактически говорим серверу, что этой БД можно доверять)
--Если мы открепим БД и вновь ее прикрепим, то это свойство сбросится в OFF
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

USE WideWorldImporters

CREATE MESSAGE TYPE
[//WWI/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML; 
CREATE MESSAGE TYPE
[//WWI/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 

GO
CREATE TABLE dbo.InvoicesReport (
    InvoicesReportId uniqueidentifier DEFAULT NEWID(),
    CustomerId int,
    StartDate date,
    EndDate date,
    InvoiceCount int,
	CONSTRAINT [PK_InvoicesReport] PRIMARY KEY CLUSTERED 
	(
		[InvoicesReportId] ASC
	)
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE MESSAGE TYPE
[//WWI/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML; 
CREATE MESSAGE TYPE
[//WWI/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 

CREATE CONTRACT [//WWI/SB/InvoicesReport]
      ([//WWI/SB/RequestMessage]
         SENT BY INITIATOR,
       [//WWI/SB/ReplyMessage]
         SENT BY TARGET
      );

CREATE QUEUE TargetInvoicesReportQueue;
CREATE SERVICE [//WWI/SB/TargetService]
       ON QUEUE TargetInvoicesReportQueue
       ([//WWI/SB/InvoicesReport]);

CREATE QUEUE InitiatorInvoicesReportQueue;
CREATE SERVICE [//WWI/SB/InitiatorService]
       ON QUEUE InitiatorInvoicesReportQueue
       ([//WWI/SB/InvoicesReport]);

GO
CREATE or ALTER PROCEDURE dbo.SendRequestInvoicesReport
    @CustomerId int,
    @StartDate date,
    @EndDate date
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
    DECLARE @RequestMessage NVARCHAR(4000);
    
    SET @RequestMessage = N'<Root>
        <CustomerId>' + CONVERT(NVARCHAR, @CustomerId) + '</CustomerId>
        <StartDate>' + CONVERT(NVARCHAR(10), @StartDate, 120) + '</StartDate>
        <EndDate>' + CONVERT(NVARCHAR(10), @EndDate, 120) + '</EndDate>
    </Root>';
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        BEGIN DIALOG @InitDlgHandle
            FROM SERVICE[//WWI/SB/InitiatorService]
            TO SERVICE N'//WWI/SB/TargetService'
            ON CONTRACT [//WWI/SB/InvoicesReport]
            WITH ENCRYPTION = OFF;
        
        SEND ON CONVERSATION @InitDlgHandle
            MESSAGE TYPE [//WWI/SB/RequestMessage] (@RequestMessage);
        
        END CONVERSATION @InitDlgHandle;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;



GO
CREATE or ALTER PROCEDURE dbo.ConfirmRequestInvoicesReport
AS
BEGIN
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000)
	
	BEGIN TRY
		BEGIN TRANSACTION; 

			RECEIVE TOP(1)
				@InitiatorReplyDlgHandle=Conversation_Handle
				,@ReplyReceivedMessage=Message_Body
			FROM dbo.InitiatorInvoicesReportQueue; 
		
			END CONVERSATION @InitiatorReplyDlgHandle;

		COMMIT TRANSACTION; 
	END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;

GO
CREATE or ALTER PROCEDURE dbo.ProcessInvoicesReport
AS
BEGIN
	DECLARE @ConvHandle UNIQUEIDENTIFIER;
    DECLARE @ConvMessage NVARCHAR(4000);
    DECLARE @ConvMessageType sysname;
    
	DECLARE @CustomerId int;
    DECLARE @StartDate date;
    DECLARE @EndDate date;
    
	DECLARE @InvoiceIdCount int;
    DECLARE @XmlDocument XML;

    BEGIN TRY
        BEGIN TRANSACTION;
        
        RECEIVE TOP(1)
            @ConvHandle = conversation_handle,
            @ConvMessage = message_body,
            @ConvMessageType = message_type_name
        FROM dbo.TargetInvoicesReportQueue;
            
        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
            
        IF @ConvMessageType = N'//WWI/SB/RequestMessage'
        BEGIN
            SET @XmlDocument = CAST(@ConvMessage AS XML);
                
            SELECT 
                @CustomerId = @XmlDocument.value('(Root/CustomerId)[1]', 'int'),
                @StartDate = @XmlDocument.value('(Root/StartDate)[1]', 'date'),
                @EndDate = @XmlDocument.value('(Root/EndDate)[1]', 'date');
            
			IF (@CustomerId IS NOT NULL)
			BEGIN
				SELECT
					@InvoiceIdCount = COUNT(Inv.InvoiceID)
				FROM
					Sales.Invoices AS Inv
					JOIN Sales.Orders AS orders ON orders.OrderID = Inv.OrderID
					JOIN Sales.Customers AS customers ON orders.CustomerID = customers.CustomerID
				WHERE
					customers.CustomerID = @CustomerId
					AND 
					Inv.InvoiceDate BETWEEN @StartDate AND @EndDate

				INSERT INTO 
					dbo.InvoicesReport (CustomerId, StartDate, EndDate, InvoiceCount) 
				VALUES 
					(@CustomerId, @StartDate, @EndDate, @InvoiceIdCount);
			END;
        END;
            
        IF @ConvHandle IS NOT NULL
        BEGIN
            END CONVERSATION @ConvHandle;
        END;
            
        COMMIT TRANSACTION;
            
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
		IF @ConvHandle IS NOT NULL
        BEGIN
            END CONVERSATION @ConvHandle WITH CLEANUP;
        END;
    END CATCH;
END;

GO
ALTER QUEUE [dbo].[InitiatorInvoicesReportQueue] 
WITH STATUS = ON --OFF=очередь НЕ доступна(ставим если глобальные проблемы)
,RETENTION = OFF --ON=все завершенные сообщения хранятся в очереди до окончания диалога
,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=после 5 ошибок очередь будет отключена
,ACTIVATION (STATUS = ON --OFF=очередь не активирует ХП(в PROCEDURE_NAME)(ставим на время исправления ХП, но с потерей сообщений)  
			,PROCEDURE_NAME = dbo.ConfirmRequestInvoicesReport
			,MAX_QUEUE_READERS = 1 --количество потоков(ХП одновременно вызванных) при обработке сообщений(0-32767)
									--(0=тоже не позовется процедура)(ставим на время исправления ХП, без потери сообщений) 
			,EXECUTE AS OWNER --учетка от имени которой запустится ХП
			);

GO
ALTER QUEUE [dbo].[TargetInvoicesReportQueue] WITH STATUS = ON 
                                       ,RETENTION = OFF 
									   ,POISON_MESSAGE_HANDLING (STATUS = OFF)
									   ,ACTIVATION (STATUS = ON 
									               ,PROCEDURE_NAME = dbo.ProcessInvoicesReport
												   ,MAX_QUEUE_READERS = 1
												   ,EXECUTE AS OWNER 
												   );

GO
EXEC dbo.SendRequestInvoicesReport 1, '2010-01-01', '2025-12-31'
EXEC dbo.SendRequestInvoicesReport 2, '2010-01-01', '2025-12-31'
EXEC dbo.SendRequestInvoicesReport 3, '2010-01-01', '2025-12-31'
EXEC dbo.SendRequestInvoicesReport 4, '2010-01-01', '2025-12-31'



