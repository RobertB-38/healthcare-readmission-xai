-- Calculate final cohort size with ALL exclusion criteria
SELECT 
  COUNT(*) as final_cohort_size,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM `physionet-data.mimiciv_3_1_hosp.admissions`), 2) as percentage_of_total
FROM `physionet-data.mimiciv_3_1_hosp.admissions` a
JOIN `physionet-data.mimiciv_3_1_hosp.patients` p 
  ON a.subject_id = p.subject_id
WHERE 
  -- Valid discharge time exists
  a.dischtime IS NOT NULL
  -- Exclude deaths during admission
  AND a.hospital_expire_flag = 0
  -- Adults only (age >= 18)
  AND p.anchor_age >= 18
  -- Valid length of stay (>= 24 hours, excludes negative/zero)
  AND DATETIME_DIFF(a.dischtime, a.admittime, HOUR) >= 24
  -- Exclude elective admissions (planned procedures)
  AND a.admission_type != 'ELECTIVE';