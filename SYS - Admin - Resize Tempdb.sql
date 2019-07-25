-- To modify the initial size of tempdb files --
use MASTER;
GO
ALTER DATABASE Tempdb
MODIFY FILE (NAME = 'tempdev', SIZE = 5000MB); --this size can be amended to what you require
ALTER DATABASE Tempdb
MODIFY FILE (NAME = 'templog', SIZE = 512MB); --this size can be amended to what you require
GO


-- Once this has been run it is necessary to restart the SQL Server services.