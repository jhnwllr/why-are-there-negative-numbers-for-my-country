SELECT 
    dataset_id,
    publisher_id,
    COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END) AS jan_2026_count,
    COUNT(CASE WHEN snapshot = '2026-04-01' THEN 1 END) AS apr_2026_count,
    (COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END) - 
     COUNT(CASE WHEN snapshot = '2026-04-01' THEN 1 END)) AS records_lost,
    ROUND(((COUNT(CASE WHEN snapshot = '2026-04-01' THEN 1 END) - 
            COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END)) * 100.0 /
           NULLIF(COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END), 0)), 2) AS pct_change
FROM hive.analytics.snapshots
WHERE snapshot IN ('2026-01-01', '2026-04-01')
    AND publisher_country = 'NO'
GROUP BY dataset_id, publisher_id
HAVING COUNT(CASE WHEN snapshot = '2026-01-01' THEN 1 END) > 
       COUNT(CASE WHEN snapshot = '2026-04-01' THEN 1 END)
ORDER BY records_lost DESC;