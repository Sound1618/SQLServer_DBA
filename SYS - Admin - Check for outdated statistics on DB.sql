SELECT 
	OBJECT_NAME(id)
	, name
	, STATS_DATE(id, indid)
	, rowmodctr
FROM sys.sysindexes
WHERE STATS_DATE(id, indid)<=DATEADD(DAY,-1,GETDATE()) 
AND rowmodctr>0 
--AND id IN (SELECT object_id FROM sys.tables)
ORDER BY 3 ASC