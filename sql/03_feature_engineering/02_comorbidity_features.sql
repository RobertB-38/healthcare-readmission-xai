-- ============================================================================
-- COMORBIDITY FEATURES - CHARLSON COMORBIDITY INDEX
-- ============================================================================
-- Purpose: Calculate Charlson Comorbidity Index and major disease flags

WITH cohort AS (
  SELECT DISTINCT
    a.subject_id,
    a.hadm_id
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

diagnoses AS (
  SELECT 
    d.subject_id,
    d.hadm_id,
    d.icd_code,
    d.icd_version
  FROM `physionet-data.mimiciv_3_1_hosp.diagnoses_icd` d
  INNER JOIN cohort c
    ON d.hadm_id = c.hadm_id
)

SELECT 
  subject_id,
  hadm_id,
  
  -- Total diagnosis count
  COUNT(DISTINCT icd_code) as num_diagnoses,
  
  -- Charlson Comorbidity Components (ICD-10 codes)
  -- Myocardial Infarction
  MAX(CASE WHEN icd_code LIKE 'I21%' OR icd_code LIKE 'I22%' OR icd_code LIKE 'I252%' THEN 1 ELSE 0 END) as cci_mi,
  
  -- Congestive Heart Failure
  MAX(CASE WHEN icd_code LIKE 'I50%' OR icd_code LIKE 'I110%' OR icd_code LIKE 'I130%' OR icd_code LIKE 'I132%' THEN 1 ELSE 0 END) as cci_chf,
  
  -- Peripheral Vascular Disease
  MAX(CASE WHEN icd_code LIKE 'I70%' OR icd_code LIKE 'I71%' OR icd_code LIKE 'I731%' OR icd_code LIKE 'I738%' OR icd_code LIKE 'I739%' OR icd_code LIKE 'I771%' OR icd_code LIKE 'I790%' OR icd_code LIKE 'I792%' THEN 1 ELSE 0 END) as cci_pvd,
  
  -- Cerebrovascular Disease
  MAX(CASE WHEN icd_code LIKE 'I60%' OR icd_code LIKE 'I61%' OR icd_code LIKE 'I62%' OR icd_code LIKE 'I63%' OR icd_code LIKE 'I65%' OR icd_code LIKE 'I66%' OR icd_code LIKE 'G45%' OR icd_code LIKE 'G46%' THEN 1 ELSE 0 END) as cci_cvd,
  
  -- Dementia
  MAX(CASE WHEN icd_code LIKE 'F00%' OR icd_code LIKE 'F01%' OR icd_code LIKE 'F02%' OR icd_code LIKE 'F03%' OR icd_code LIKE 'G30%' THEN 1 ELSE 0 END) as cci_dementia,
  
  -- COPD
  MAX(CASE WHEN icd_code LIKE 'J40%' OR icd_code LIKE 'J41%' OR icd_code LIKE 'J42%' OR icd_code LIKE 'J43%' OR icd_code LIKE 'J44%' OR icd_code LIKE 'J47%' THEN 1 ELSE 0 END) as cci_copd,
  
  -- Diabetes without complications
  MAX(CASE WHEN icd_code LIKE 'E10%' OR icd_code LIKE 'E11%' OR icd_code LIKE 'E12%' OR icd_code LIKE 'E13%' OR icd_code LIKE 'E14%' THEN 1 ELSE 0 END) as cci_diabetes,
  
  -- Chronic Kidney Disease
  MAX(CASE WHEN icd_code LIKE 'N18%' OR icd_code LIKE 'N19%' THEN 1 ELSE 0 END) as cci_ckd,
  
  -- Cancer (any malignancy)
  MAX(CASE WHEN icd_code LIKE 'C%' THEN 1 ELSE 0 END) as cci_cancer

FROM diagnoses
GROUP BY subject_id, hadm_id
LIMIT 1000;