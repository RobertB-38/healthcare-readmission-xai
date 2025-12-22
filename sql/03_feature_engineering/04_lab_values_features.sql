-- ============================================================================
-- LAB VALUES FEATURES - ABNORMAL FLAGS AND COUNTS
-- ============================================================================
-- Purpose: Extract lab abnormalities from first 24 hours of admission

WITH cohort AS (
  SELECT DISTINCT
    a.subject_id,
    a.hadm_id,
    a.admittime,
    a.dischtime
  FROM `physionet-data.mimiciv_3_1_hosp.admissions` a
  JOIN `physionet-data.mimiciv_3_1_hosp.patients` p 
    ON a.subject_id = p.subject_id
  WHERE 
    a.dischtime IS NOT NULL
    AND a.hospital_expire_flag = 0
    AND p.anchor_age >= 18
    AND DATETIME_DIFF(a.dischtime, a.admittime, HOUR) >= 24
    AND a.admission_type != 'ELECTIVE'
),

labs_first_24h AS (
  SELECT 
    le.subject_id,
    le.hadm_id,
    le.itemid,
    le.charttime,
    le.valuenum,
    le.flag  -- abnormal flag from MIMIC
  FROM `physionet-data.mimiciv_3_1_hosp.labevents` le
  INNER JOIN cohort c
    ON le.hadm_id = c.hadm_id
  WHERE 
    le.charttime >= c.admittime
    AND le.charttime <= DATETIME_ADD(c.admittime, INTERVAL 24 HOUR)
    AND le.valuenum IS NOT NULL
)

SELECT 
  subject_id,
  hadm_id,
  
  -- Total lab tests in first 24h
  COUNT(*) as num_lab_tests_24h,
  
  -- Abnormal lab flags
  SUM(CASE WHEN flag = 'abnormal' THEN 1 ELSE 0 END) as num_abnormal_labs,
  
  -- Specific critical lab indicators (common MIMIC itemids)
  -- Hemoglobin (low = anemia)
  MIN(CASE WHEN itemid IN (51222, 50811) THEN valuenum END) as hemoglobin_min,
  
  -- White Blood Cell count (high = infection)
  MAX(CASE WHEN itemid IN (51301, 51300) THEN valuenum END) as wbc_max,
  
  -- Creatinine (high = kidney dysfunction)
  MAX(CASE WHEN itemid = 50912 THEN valuenum END) as creatinine_max,
  
  -- Sodium (abnormal = electrolyte imbalance)
  MIN(CASE WHEN itemid = 50983 THEN valuenum END) as sodium_min,
  MAX(CASE WHEN itemid = 50983 THEN valuenum END) as sodium_max,
  
  -- Potassium (abnormal = cardiac risk)
  MIN(CASE WHEN itemid = 50971 THEN valuenum END) as potassium_min,
  MAX(CASE WHEN itemid = 50971 THEN valuenum END) as potassium_max,
  
  -- Glucose (abnormal = diabetes control)
  MIN(CASE WHEN itemid = 50931 THEN valuenum END) as glucose_min,
  MAX(CASE WHEN itemid = 50931 THEN valuenum END) as glucose_max

FROM labs_first_24h
GROUP BY subject_id, hadm_id
LIMIT 1000;