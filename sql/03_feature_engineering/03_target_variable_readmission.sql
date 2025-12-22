-- ============================================================================
-- TARGET VARIABLE - 30/60/90 DAY READMISSION FLAGS
-- ============================================================================
-- Purpose: Calculate readmission within 30, 60, and 90 days

WITH cohort AS (
  SELECT 
    a.subject_id,
    a.hadm_id,
    a.admittime,
    a.dischtime,
    LEAD(a.admittime) OVER (PARTITION BY a.subject_id ORDER BY a.admittime) as next_admittime,
    DATETIME_DIFF(
      LEAD(a.admittime) OVER (PARTITION BY a.subject_id ORDER BY a.admittime),
      a.dischtime,
      DAY
    ) as days_to_next_admission
  FROM `physionet-data.mimiciv_3_1_hosp.admissions` a
  JOIN `physionet-data.mimiciv_3_1_hosp.patients` p 
    ON a.subject_id = p.subject_id
  WHERE 
    a.dischtime IS NOT NULL
    AND a.hospital_expire_flag = 0
    AND p.anchor_age >= 18
    AND DATETIME_DIFF(a.dischtime, a.admittime, HOUR) >= 24
    AND a.admission_type != 'ELECTIVE'
)

SELECT 
  subject_id,
  hadm_id,
  dischtime,
  next_admittime,
  days_to_next_admission,
  
  -- Target variables
  CASE WHEN days_to_next_admission IS NOT NULL AND days_to_next_admission <= 30 THEN 1 ELSE 0 END as readmitted_30d,
  CASE WHEN days_to_next_admission IS NOT NULL AND days_to_next_admission <= 60 THEN 1 ELSE 0 END as readmitted_60d,
  CASE WHEN days_to_next_admission IS NOT NULL AND days_to_next_admission <= 90 THEN 1 ELSE 0 END as readmitted_90d

FROM cohort
ORDER BY subject_id, dischtime
LIMIT 1000;