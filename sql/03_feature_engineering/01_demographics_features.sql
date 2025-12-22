-- ============================================================================
-- DEMOGRAPHIC FEATURES EXTRACTION
-- ============================================================================
-- Purpose: Extract patient demographic features for readmission prediction

SELECT 
  a.subject_id,
  a.hadm_id,
  
  -- Demographics
  p.gender,
  p.anchor_age as age,
  a.race,
  a.marital_status,
  a.language,
  a.insurance,
  
  -- Admission characteristics
  a.admission_type,
  a.admission_location,
  a.discharge_location,
  
  -- Length of stay
  DATETIME_DIFF(a.dischtime, a.admittime, HOUR) as los_hours,
  DATETIME_DIFF(a.dischtime, a.admittime, DAY) as los_days,
  
  -- Timestamps (for temporal validation later)
  a.admittime,
  a.dischtime,
  
  -- Target variable placeholder (we'll calculate this separately)
  a.hadm_id as index_admission_id

FROM `physionet-data.mimiciv_3_1_hosp.admissions` a
JOIN `physionet-data.mimiciv_3_1_hosp.patients` p 
  ON a.subject_id = p.subject_id

WHERE 
  -- Apply same cohort filters
  a.dischtime IS NOT NULL
  AND a.hospital_expire_flag = 0
  AND p.anchor_age >= 18
  AND DATETIME_DIFF(a.dischtime, a.admittime, HOUR) >= 24
  AND a.admission_type != 'ELECTIVE'

ORDER BY a.subject_id, a.admittime
LIMIT 1000;  -- Test with 1000 rows first
