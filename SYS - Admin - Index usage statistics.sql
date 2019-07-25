USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[DBA_indexUsageStatsPersistsHistory]    Script Date: 05/04/2019 10:57:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Credit to Raul Gonzalez Coeo


ALTER PROCEDURE [dbo].[DBA_indexUsageStatsPersistsHistory] 
	@dbname			SYSNAME = NULL 
	, @object_id	INT = NULL 
	, @index_id		INT = NULL 
	, @debugging	BIT = 0 
AS 
BEGIN 
 
SET NOCOUNT ON 
 
DECLARE @sql								NVARCHAR(MAX) 
		
 
SET @debugging = ISNULL(@debugging, 0) 
 
IF @object_id IS NULL AND @index_id IS NOT NULL BEGIN 
	RAISERROR (N'You cannot specify @index_id without specifying @object_id', 16, 1, 1) 
	RETURN -100 
END 
 
DECLARE @db TABLE(database_id INT NOT NULL PRIMARY KEY, database_name SYSNAME NOT NULL)
 
INSERT INTO @db (database_id, database_name)
	SELECT database_id, name FROM sys.databases WHERE database_id > 4 and state_desc = 'ONLINE'
 
DECLARE dbs CURSOR LOCAL FORWARD_ONLY READ_ONLY FAST_FORWARD FOR 
	SELECT db.database_name
		FROM @db AS db 
			WHERE db.database_name LIKE ISNULL(@dbname, db.database_name) 
 
OPEN dbs 
FETCH NEXT FROM dbs INTO @dbname
 
WHILE @@FETCH_STATUS = 0 BEGIN 


PRINT N'Processing database : ' + QUOTENAME(@dbname) 
 
	SET @sql = N'USE ' + QUOTENAME(@dbname) + CONVERT(NVARCHAR(MAX), N' 
 
;WITH s AS ( 
SELECT @@SERVERNAME AS server_name 
			, DB_ID() AS [database_id] 
			, DB_NAME() AS [database_name] 
			, OBJECT_SCHEMA_NAME(ix.object_id) AS [schema_name] 
			, ix.object_id 
			, OBJECT_NAME(ix.object_id) AS [object_name] 
			, ix.index_id 
			, ix.name AS [index_name] 
			, ISNULL(ius.[user_seeks]	, 0) AS [user_seeks]	 
			, ISNULL(ius.[user_scans]	, 0) AS [user_scans]	 
			, ISNULL(ius.[user_lookups]	, 0) AS [user_lookups] 
			, ISNULL(ius.[user_updates]	, 0) AS [user_updates] 
			, ius.[last_user_seek] 
			, ius.[last_user_scan] 
			, ius.[last_user_lookup] 
			, ius.[last_user_update] 
			, ISNULL(ius.[system_seeks]	 , 0) AS [system_seeks] 
			, ISNULL(ius.[system_scans]	 , 0) AS [system_scans] 
			, ISNULL(ius.[system_lookups], 0) AS [system_lookups] 
			, ISNULL(ius.[system_updates], 0) AS [system_updates] 
			, ius.[last_system_seek] 
			, ius.[last_system_scan] 
			, ius.[last_system_lookup] 
			, ius.[last_system_update] 
 
		FROM sys.indexes AS ix WITH(NOLOCK) 
			LEFT JOIN sys.dm_db_index_usage_stats AS ius WITH(NOLOCK) 
				ON ius.object_id = ix.object_id 
					AND ius.index_id = ix.index_id 
					AND ius.database_id = DB_ID() 
		WHERE ix.object_id	= ISNULL(@object_id, ix.object_id) 
			AND ix.index_id	= ISNULL(@index_id, ix.index_id) 
			AND OBJECTPROPERTYEX(ix.object_id, ''IsMsShipped'') = 0 
) 
 
MERGE [DBA].[dbo].[IndexUsageStatsHistory] AS t 
	USING s 
		ON s.server_name				= t.server_name 
		AND s.database_name				= t.database_name  
		AND s.object_id					= t.object_id  
		AND s.index_id					= t.index_id  
		AND ISNULL(s.index_name, '''')	= ISNULL(t.index_name, '''')  COLLATE DATABASE_DEFAULT
	WHEN NOT MATCHED THEN  
		INSERT ([server_name],[database_id],[database_name],[schema_name],[object_id],[object_name],[index_id],[index_name] 
				,[total_user_seeks],[total_user_scans],[total_user_lookups],[total_user_updates] 
				,[user_seeks],[user_scans],[user_lookups],[user_updates] 
				,[last_user_seek],[last_user_scan],[last_user_lookup],[last_user_update] 
				,[total_system_seeks],[total_system_scans],[total_system_lookups],[total_system_updates] 
				,[system_seeks],[system_scans],[system_lookups],[system_updates] 
				,[last_system_seek],[last_system_scan],[last_system_lookup],[last_system_update],[created_date],[modified_date]) 
 
		VALUES ([server_name],[database_id],[database_name],[schema_name],[object_id],[object_name],[index_id],[index_name] 
				,[user_seeks],[user_scans],[user_lookups],[user_updates] -- Same for total_ and user_ 
				,[user_seeks],[user_scans],[user_lookups],[user_updates] -- Same for total_ and user_ 
				,[last_user_seek],[last_user_scan],[last_user_lookup],[last_user_update] 
				,[system_seeks],[system_scans],[system_lookups],[system_updates] -- Same for total_ and system_ 
				,[system_seeks],[system_scans],[system_lookups],[system_updates] -- Same for total_ and system_ 
				,[last_system_seek],[last_system_scan],[last_system_lookup],[last_system_update],GETDATE(),GETDATE()) 
 
	WHEN MATCHED THEN UPDATE SET 
		t.[total_user_seeks]		+= CASE WHEN t.[user_seeks]		> s.[user_seeks]	THEN s.[user_seeks]		ELSE s.[user_seeks]		- t.[user_seeks]	END --- cumulative			 
		, t.[total_user_scans]		+= CASE WHEN t.[user_scans]		> s.[user_scans]	THEN s.[user_scans]		ELSE s.[user_scans]		- t.[user_scans]	END -- cumulative 
		, t.[total_user_lookups]	+= CASE WHEN t.[user_lookups]	> s.[user_lookups]	THEN s.[user_lookups]	ELSE s.[user_lookups]	- t.[user_lookups]	END -- cumulative 
		, t.[total_user_updates]	+= CASE WHEN t.[user_updates] 	> s.[user_updates] 	THEN s.[user_updates] 	ELSE s.[user_updates] 	- t.[user_updates] 	END -- cumulative 
		, t.[user_seeks]			= s.[user_seeks] 
		, t.[user_scans]			= s.[user_scans] 
		, t.[user_lookups]			= s.[user_lookups] 
		, t.[user_updates]			= s.[user_updates] 
		, t.[last_user_seek]		= s.[last_user_seek]		 
		, t.[last_user_scan]		= s.[last_user_scan]		 
		, t.[last_user_lookup]		= s.[last_user_lookup]		 
		, t.[last_user_update]		= s.[last_user_update]		 
		, t.[total_system_seeks]	+= CASE WHEN t.[system_seeks]	> s.[system_seeks]		THEN s.[system_seeks]	ELSE s.[system_seeks]	- t.[system_seeks]		END-- cumulative		 
		, t.[total_system_scans]	+= CASE WHEN t.[system_scans]	> s.[system_scans]		THEN s.[system_scans]	ELSE s.[system_scans]	- t.[system_scans]		END-- cumulative 
		, t.[total_system_lookups]	+= CASE WHEN t.[system_lookups]	> s.[system_lookups]	THEN s.[system_lookups]	ELSE s.[system_lookups]	- t.[system_lookups]	END-- cumulative 
		, t.[total_system_updates]	+= CASE WHEN t.[system_updates]	> s.[system_updates]	THEN s.[system_updates]	ELSE s.[system_updates]	- t.[system_updates]	END-- cumulative 
		, t.[system_seeks]			= s.[system_seeks] 
		, t.[system_scans]			= s.[system_scans] 
		, t.[system_lookups]		= s.[system_lookups] 
		, t.[system_updates]		= s.[system_updates] 
		, t.[last_system_seek]		= s.[last_system_seek]		 
		, t.[last_system_scan]		= s.[last_system_scan]		 
		, t.[last_system_lookup]	= s.[last_system_lookup]	 
		, t.[last_system_update]	= s.[last_system_update] 
		, t.[modified_date]			= GETDATE() 
	; 
') 
	 
	IF @debugging = 0 
		EXECUTE sp_executesql 
			@stmt = @sql
			, @params = N'@object_id INT, @index_id INT'
			, @object_id = @object_id
			, @index_id = @index_id 
	ELSE 
		PRINT @sql 
 
	FETCH NEXT FROM dbs INTO @dbname
 
END 
 
CLOSE dbs 
DEALLOCATE dbs 
 
END 
 
