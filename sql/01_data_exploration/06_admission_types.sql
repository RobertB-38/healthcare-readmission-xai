-- What types of admissions exist?
SELECT 
  admission_type,
  COUNT(*) as num_admissions,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as percentage
FROM `physionet-data.mimiciv_3_1_hosp.admissions`
GROUP BY admission_type
ORDER BY num_admissions DESC;
