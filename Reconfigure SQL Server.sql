GO

sp_configure 'show advanced options', 1

GO

RECONFIGURE;

GO

sp_configure 'backup compression default',1

GO

RECONFIGURE;

GO

sp_configure 'cost threshold for parallelism',25

GO

RECONFIGURE;

GO

sp_configure 'max degree of parallelism',2

GO

RECONFIGURE;

GO

sp_configure 'max worker threads',1200

GO

RECONFIGURE;

GO

sp_configure 'optimize for ad hoc workloads',1

GO

RECONFIGURE;

GO

sp_configure 'scan for startup procs',1

GO

RECONFIGURE;

GO

sp_configure 'xp_cmdshell',1

GO

RECONFIGURE;

GO

sp_configure 'Ole Automation Procedures', 1;

GO

RECONFIGURE;

GO