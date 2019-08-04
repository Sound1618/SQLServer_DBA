-- Use the following script to kill all associated spid's linked to a DB
-- If the bit variable of @AlterDatabase is set to 1 then the database will be set to multi-user mode as well
-- Replace XXX by Database Name

USE [master];

DECLARE 
	@Database		varchar(30) = 'XXX',
	@AlterDatabase	bit = 1

DECLARE
	@kill			varchar(8000) = '',
	@Alter			varchar(100) = '',
	@Processes		int;
SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), session_id) + ';'  
FROM sys.dm_exec_sessions
WHERE database_id  = db_id(@Database)
SET @Processes = @@ROWCOUNT

EXEC(@kill)

IF @AlterDatabase = 1
BEGIN
	
	SELECT @Alter = @Alter + 'ALTER DATABASE ' + @Database + ' SET MULTI_USER'
	EXEC (@Alter)
	PRINT CAST(@Processes AS varchar(5)) +' processes linked to '+ @Database +' killed'
	PRINT @Database + ' updated to multi-user mode'

END
ELSE
BEGIN
	PRINT CAST(@Processes AS varchar(5)) +' processes killed'

END
