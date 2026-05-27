-- ===================================================================
-- POLAND DATASETS WITH REDUCED RECORDS (JAN 2026 - APR 2026)
-- Query to find all Polish datasets that lost records between snapshots
-- Execute: java -jar trino.jar --insecure --server https://c8n1.gbif.org:31843 --catalog hive --schema analytics --user gbif --password --file poland_datasets_deleted.sql
-- ===================================================================

-- STEP 0: Find available snapshot dates (run this first to confirm dates)
-- Uncomment to see what snapshot dates are available for Poland
-- SELECT DISTINCT snapshot 
-- FROM hive.analytics.snapshots 
-- WHERE publisher_country = 'PL' 
-- ORDER BY snapshot DESC 
-- LIMIT 10;

-- Version 1: RECOMMENDED - Simple aggregated query with most recent snapshot with most recent snapshot
-- Start with this one - it's the most straightforward
-- Using actual snapshots schema: each row is an occurrence record
-- NOTE: Change '2026-05-01' to the actual most recent snapshot date available
SELECT 
    dataset_id,
    publisher_id,
    COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END) AS jan_2026_count,
    COUNT(CASE WHEN snapshot = '2026-04-01' THEN 1 END) AS apr_2026_count,
    COUNT(CASE WHEN snapshot = '2026-05-01' THEN 1 END) AS may_2026_count,
    (COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END) - 
     COUNT(CASE WHEN snapshot = '2026-04-01' THEN 1 END)) AS records_lost_jan_to_apr,
    (COUNT(CASE WHEN snapshot = '2026-04-01' THEN 1 END) - 
     COUNT(CASE WHEN snapshot = '2026-05-01' THEN 1 END)) AS records_lost_apr_to_may,
    (COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END) - 
     COUNT(CASE WHEN snapshot = '2026-05-01' THEN 1 END)) AS total_records_lost,
    ROUND(((COUNT(CASE WHEN snapshot = '2026-04-01' THEN 1 END) - 
            COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END)) * 100.0 /
           NULLIF(COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END), 0)), 2) AS pct_change_jan_to_apr,
    ROUND(((COUNT(CASE WHEN snapshot = '2026-05-01' THEN 1 END) - 
            COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END)) * 100.0 /
           NULLIF(COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END), 0)), 2) AS pct_change_jan_to_may
FROM hive.analytics.snapshots
WHERE snapshot IN ('2026-01-01', '2026-04-01', '2026-05-01')
    AND publisher_country = 'PL'
GROUP BY dataset_id, publisher_id
HAVING COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END) > 
       COUNT(CASE WHEN snapshot = '2026-04-01' THEN 1 END)
ORDER BY records_lost_jan_to_apr DESC;

-- Version 2: WITH CTEs - More readable, same results
-- Use this if you prefer clearer SQL structure
-- WITH jan_poland AS (
--     SELECT 
--         dataset_id,
--         publisher_id,
--         COUNT(*) AS jan_count
--     FROM hive.analytics.snapshots
--     WHERE snapshot = '2026-01-01'
--         AND publisher_country = 'PL'
--     GROUP BY dataset_id, publisher_id
-- ),
-- apr_poland AS (
--     SELECT 
--         dataset_id,
--         publisher_id,
--         COUNT(*) AS apr_count
--     FROM hive.analytics.snapshots
--     WHERE snapshot = '2026-04-01'
--         AND publisher_country = 'PL'
--     GROUP BY dataset_id, publisher_id
-- )
-- SELECT 
--     COALESCE(jan_poland.dataset_id, apr_poland.dataset_id) AS dataset_id,
--     COALESCE(jan_poland.publisher_id, apr_poland.publisher_id) AS publisher_id,
--     COALESCE(jan_poland.jan_count, 0) AS jan_2026_count,
--     COALESCE(apr_poland.apr_count, 0) AS apr_2026_count,
--     (COALESCE(jan_poland.jan_count, 0) - COALESCE(apr_poland.apr_count, 0)) AS records_lost,
--     CASE 
--         WHEN jan_poland.jan_count > 0 
--         THEN ROUND(((COALESCE(apr_poland.apr_count, 0) - COALESCE(jan_poland.jan_count, 0)) * 100.0 / jan_poland.jan_count), 2)
--         ELSE NULL 
--     END AS pct_change
-- FROM jan_poland
-- FULL OUTER JOIN apr_poland 
--     ON jan_poland.dataset_id = apr_poland.dataset_id 
--     AND jan_poland.publisher_id = apr_poland.publisher_id
-- WHERE (COALESCE(jan_poland.jan_count, 0) - COALESCE(apr_poland.apr_count, 0)) > 0
-- ORDER BY records_lost DESC;

-- Summary statistics for Poland
-- Uncomment to get overall Poland statistics
-- SELECT 
--     'Total Poland datasets in Jan 2026' AS metric,
--     COUNT(DISTINCT dataset_id) AS value
-- FROM hive.analytics.snapshots
-- WHERE snapshot = '2026-01-01' AND publisher_country = 'PL'
-- UNION ALL
-- SELECT 
--     'Total Poland datasets in Apr 2026' AS metric,
--     COUNT(DISTINCT dataset_id) AS value
-- FROM hive.analytics.snapshots
-- WHERE snapshot = '2026-04-01' AND publisher_country = 'PL'
-- UNION ALL
-- SELECT 
--     'Total Poland datasets in May 2026' AS metric,
--     COUNT(DISTINCT dataset_id) AS value
-- FROM hive.analytics.snapshots
-- WHERE snapshot = '2026-05-01' AND publisher_country = 'PL'
-- UNION ALL
-- SELECT 
--     'Total Poland records in Jan 2026' AS metric,
--     COUNT(*) AS value
-- FROM hive.analytics.snapshots
-- WHERE snapshot = '2026-01-01' AND publisher_country = 'PL'
-- UNION ALL
-- SELECT 
--     'Total Poland records in Apr 2026' AS metric,
--     COUNT(*) AS value
-- FROM hive.analytics.snapshots
-- WHERE snapshot = '2026-04-01' AND publisher_country = 'PL'
-- UNION ALL
-- SELECT 
--     'Total Poland records in May 2026' AS metric,
--     COUNT(*) AS value
-- FROM hive.analytics.snapshots
-- WHERE snapshot = '2026-05-01' AND publisher_country = 'PL';
