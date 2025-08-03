IF EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'HW14Logger')
BEGIN
	DROP TABLE [dbo].[HW14Logger];
END
