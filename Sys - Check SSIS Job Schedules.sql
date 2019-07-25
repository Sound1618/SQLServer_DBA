SELECT *
FROM   msdb.dbo.sysmaintplan_plans p
       INNER JOIN msdb.dbo.sysmaintplan_subplans sp
         ON p.id = sp.plan_id
       LEFT OUTER JOIN msdb.dbo.sysjobschedules j
         ON j.schedule_id = sp.schedule_id  