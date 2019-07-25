-- Replace XXX by the Database Name

EXECUTE [dbo].[IndexOptimize]
@Databases = 'XXX',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REBUILD_ONLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE',
@UpdateStatistics = 'ALL',
@LogToTable = 'Y'
