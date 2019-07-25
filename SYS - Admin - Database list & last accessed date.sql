------------------------------------------------------------

--Find all system databases in production

CREATE TABLE #Databases(
	Cluster nvarchar(40),
	DBName nvarchar(60),
	Created datetime,
	[Status] nvarchar(30))

INSERT INTO #Databases(
	Cluster,
	DBName,
	Created,
	[Status])

SELECT 
	db.Cluster,
	db.DBName,
	db.Created,
	db.[Status]
FROM (
	SELECT 
		'[UK-PRD-SCL-0001\INST0011]' AS [Cluster],
		d.name AS [DBName],
		d.create_date AS [Created],
		d.state_desc AS [Status]
	FROM [UK-PRD-SCL-0001\INST0011].msdb.sys.databases d

	UNION
	
	SELECT 
		'[UK-PRD-SCL-0002\INST0021]' AS [Cluster],
		d.name AS [DBName],
		d.create_date AS [Created],
		d.state_desc AS [Status]
	FROM [UK-PRD-SCL-0002\INST0021].msdb.sys.databases d
	
	UNION
	
	SELECT 
		'[NA-PRD-SCL-0001]' AS [Cluster],
		d.name COLLATE DATABASE_DEFAULT AS [DBName],
		d.create_date AS [Created],
		d.state_desc COLLATE DATABASE_DEFAULT AS [Status]
	FROM [NA-PRD-SCL-0001].msdb.sys.databases d
) AS db

------------------------------------------------------------

--Retrieve last login dates from all databases

DECLARE database_list CURSOR FAST_FORWARD READ_ONLY FOR

	SELECT DISTINCT
		d.Cluster,
		d.DBName
	FROM #Databases d
	WHERE d.DBName LIKE '%Workware'

DECLARE
	@server_name nvarchar(50)
	, @database_name nvarchar(50)
	, @sql nvarchar(MAX)

CREATE TABLE #LastLogin(
	Cluster nvarchar(40),
	DBName nvarchar(60),
	LoginDate Datetime)

OPEN database_list
FETCH NEXT FROM database_list INTO @server_name, @database_name 
WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT @sql =

	'INSERT INTO #LastLogin (
			Cluster,
			DBName,
			LoginDate)
		SELECT 
			'''+@server_name+''',
			'''+@database_name+''',
			MAX(s.Timestamp_Start) AS [LoginDate]
		FROM ' + @server_name + '.' + @database_name + '.dbo.DCSession s
		WHERE s.Timestamp_Start > ''2017'''

	--PRINT @Sql
	EXEC sp_executesql @sql

	FETCH NEXT FROM database_list INTO @server_name, @database_name
END
CLOSE database_list
DEALLOCATE database_list

SELECT 
	d.Cluster,
	d.DBName,
	l.LoginDate AS [LastLogin]
FROM #Databases d
	LEFT OUTER JOIN #LastLogin l ON d.Cluster = l.Cluster
	AND d.DBName = l.DBName

------------------------------------------------------------

--Clear up temp data

DROP TABLE #LastLogin
DROP TABLE #Databases