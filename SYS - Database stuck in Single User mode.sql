-- Selective query: Run lines 4 to 22 first to find the processes locking the database. Edit and run 28 to 33 after.
-- Replace XXX by database name

DECLARE @Table TABLE(
        SPID INT,
        Status VARCHAR(MAX),
        LOGIN VARCHAR(MAX),
        HostName VARCHAR(MAX),
        BlkBy VARCHAR(MAX),
        DBName VARCHAR(MAX),
        Command VARCHAR(MAX),
        CPUTime INT,
        DiskIO INT,
        LastBatch VARCHAR(MAX),
        ProgramName VARCHAR(MAX),
        SPID_1 INT,
        REQUESTID INT
)
INSERT INTO @Table EXEC sp_who2
SELECT  *
FROM    @Table
WHERE DBName = 'XXX'

 

---Returns the process ID (NNN) 

KILL NNN; 

USE MASTER;

ALTER DATABASE [XXX] SET MULTI_USER
GO