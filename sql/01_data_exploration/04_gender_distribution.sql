-- Male vs Female split
SELECT 
  gender,
  COUNT(*) as num_patients,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as percentage
FROM `physionet-data.mimiciv_3_1_hosp.patients`
GROUP BY gender;