-- How long do patients stay in hospital?
SELECT 
  DATETIME_DIFF(dischtime, admittime, HOUR) as los_hours,
  COUNT(*) as num_admissions
FROM `physionet-data.mimiciv_3_1_hosp.admissions`
WHERE dischtime IS NOT NULL
GROUP BY los_hours
ORDER BY los_hours
LIMIT 50;


-- Analyze length of stay WITH data quality filtering
SELECT 
  CASE 
    WHEN DATETIME_DIFF(dischtime, admittime, HOUR) < 0 THEN 'Negative (ERROR)'
    WHEN DATETIME_DIFF(dischtime, admittime, HOUR) = 0 THEN 'Zero hours (ERROR)'
    WHEN DATETIME_DIFF(dischtime, admittime, HOUR) BETWEEN 1 AND 23 THEN '1-23 hours (Exclude)'
    WHEN DATETIME_DIFF(dischtime, admittime, HOUR) BETWEEN 24 AND 48 THEN '24-48 hours (Include)'
    WHEN DATETIME_DIFF(dischtime, admittime, HOUR) BETWEEN 49 AND 168 THEN '2-7 days (Include)'
    WHEN DATETIME_DIFF(dischtime, admittime, HOUR) > 168 THEN '>7 days (Include)'
  END as los_category,
  COUNT(*) as num_admissions,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM `physionet-data.mimiciv_3_1_hosp.admissions` WHERE dischtime IS NOT NULL), 2) as percentage
FROM `physionet-data.mimiciv_3_1_hosp.admissions`
WHERE dischtime IS NOT NULL
GROUP BY los_category
ORDER BY 
  CASE los_category
    WHEN 'Negative (ERROR)' THEN 1
    WHEN 'Zero hours (ERROR)' THEN 2
    WHEN '1-23 hours (Exclude)' THEN 3
    WHEN '24-48 hours (Include)' THEN 4
    WHEN '2-7 days (Include)' THEN 5
    WHEN '>7 days (Include)' THEN 6
  END;