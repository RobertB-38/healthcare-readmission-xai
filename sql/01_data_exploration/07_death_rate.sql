-- How many patients died during hospitalization?
SELECT 
  hospital_expire_flag,
  COUNT(*) as num_admissions,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM `physionet-data.mimiciv_3_1_hosp.admissions`), 2) as percentage
FROM `physionet-data.mimiciv_3_1_hosp.admissions`
GROUP BY hospital_expire_flag;