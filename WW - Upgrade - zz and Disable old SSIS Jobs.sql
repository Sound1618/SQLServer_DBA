-- Replace Like Operator by '%_VendorPrefix_%'

DECLARE @SQLStatement VARCHAR(200)
DECLARE @jobName SYSNAME

DECLARE 
    c1 
CURSOR FOR
    SELECT
        name
    FROM
        msdb.dbo.sysjobs_view 
    WHERE
        name
    LIKE 
        '%_VendorPrefix_%' --Change the LIKE operator


OPEN c1
    FETCH NEXT FROM c1 INTO @jobName

    IF @@CURSOR_ROWS = 0
        PRINT 'No Job found! Please re-check LIKE operator.'
    
    WHILE @@fetch_status = 0
    BEGIN
        SET @SQLStatement = 'EXEC msdb.dbo.sp_update_job @job_name = ''' + @jobName + ''', @new_name =''zz' +@jobName +''''
        PRINT(@SQLStatement)
        --EXEC (@SQLStatement) --Uncomment to Execute

        SET @SQLStatement = 'EXEC msdb.dbo.sp_update_job @job_name = ''zz' + @jobName + ''', @enabled = 0'
        PRINT(@SQLStatement)
        --EXEC (@SQLStatement) --Uncomment to Execute

        FETCH NEXT FROM c1 INTO @jobName
    END
CLOSE c1
DEALLOCATE c1