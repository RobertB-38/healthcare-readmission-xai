-- ============================================================================
-- FINAL MERGED DATASET - ALL FEATURES + TARGET VARIABLE
-- ============================================================================
-- Purpose: Combine all feature tables into single modeling dataset

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

-- Demographics features
demographics AS (
  SELECT 
    a.subject_id,
    a.hadm_id,
    p.gender,
    p.anchor_age as age,
    a.race,
    a.marital_status,
    a.language,
    a.insurance,
    a.admission_type,
    a.admission_location,
    a.discharge_location,
    DATETIME_DIFF(a.dischtime, a.admittime, HOUR) as los_hours,
    DATETIME_DIFF(a.dischtime, a.admittime, DAY) as los_days
  FROM `physionet-data.mimiciv_3_1_hosp.admissions` a
  JOIN `physionet-data.mimiciv_3_1_hosp.patients` p 
    ON a.subject_id = p.subject_id
  WHERE a.hadm_id IN (SELECT hadm_id FROM cohort)
),

-- Comorbidity features
comorbidities AS (
  SELECT 
    d.subject_id,
    d.hadm_id,
    COUNT(DISTINCT d.icd_code) as num_diagnoses,
    MAX(CASE WHEN d.icd_code LIKE 'I21%' OR d.icd_code LIKE 'I22%' OR d.icd_code LIKE 'I252%' THEN 1 ELSE 0 END) as cci_mi,
    MAX(CASE WHEN d.icd_code LIKE 'I50%' OR d.icd_code LIKE 'I110%' OR d.icd_code LIKE 'I130%' OR d.icd_code LIKE 'I132%' THEN 1 ELSE 0 END) as cci_chf,
    MAX(CASE WHEN d.icd_code >= 'I70' AND d.icd_code < 'I80' THEN 1 ELSE 0 END) as cci_pvd,
    MAX(CASE WHEN (d.icd_code >= 'I60' AND d.icd_code < 'I70') OR (d.icd_code >= 'G45' AND d.icd_code < 'G47') THEN 1 ELSE 0 END) as cci_cvd,
    MAX(CASE WHEN (d.icd_code >= 'F00' AND d.icd_code < 'F04') OR d.icd_code LIKE 'G30%' THEN 1 ELSE 0 END) as cci_dementia,
    MAX(CASE WHEN (d.icd_code >= 'J40' AND d.icd_code < 'J48') THEN 1 ELSE 0 END) as cci_copd,
    MAX(CASE WHEN d.icd_code >= 'E10' AND d.icd_code < 'E15' THEN 1 ELSE 0 END) as cci_diabetes,
    MAX(CASE WHEN d.icd_code LIKE 'N18%' OR d.icd_code LIKE 'N19%' THEN 1 ELSE 0 END) as cci_ckd,
    MAX(CASE WHEN d.icd_code LIKE 'C%' THEN 1 ELSE 0 END) as cci_cancer
  FROM `physionet-data.mimiciv_3_1_hosp.diagnoses_icd` d
  WHERE d.hadm_id IN (SELECT hadm_id FROM cohort)
  GROUP BY d.subject_id, d.hadm_id
),

-- Lab values features (first 24h)
labs AS (
  SELECT 
    le.subject_id,
    le.hadm_id,
    COUNT(*) as num_lab_tests_24h,
    SUM(CASE WHEN le.flag = 'abnormal' THEN 1 ELSE 0 END) as num_abnormal_labs,
    MIN(CASE WHEN le.itemid IN (51222, 50811) THEN le.valuenum END) as hemoglobin_min,
    MAX(CASE WHEN le.itemid IN (51301, 51300) THEN le.valuenum END) as wbc_max,
    MAX(CASE WHEN le.itemid = 50912 THEN le.valuenum END) as creatinine_max,
    MIN(CASE WHEN le.itemid = 50983 THEN le.valuenum END) as sodium_min,
    MAX(CASE WHEN le.itemid = 50983 THEN le.valuenum END) as sodium_max,
    MIN(CASE WHEN le.itemid = 50971 THEN le.valuenum END) as potassium_min,
    MAX(CASE WHEN le.itemid = 50971 THEN le.valuenum END) as potassium_max,
    MIN(CASE WHEN le.itemid = 50931 THEN le.valuenum END) as glucose_min,
    MAX(CASE WHEN le.itemid = 50931 THEN le.valuenum END) as glucose_max
  FROM `physionet-data.mimiciv_3_1_hosp.labevents` le
  INNER JOIN cohort c ON le.hadm_id = c.hadm_id
  WHERE le.charttime >= c.admittime
    AND le.charttime <= DATETIME_ADD(c.admittime, INTERVAL 24 HOUR)
    AND le.valuenum IS NOT NULL
  GROUP BY le.subject_id, le.hadm_id
),

-- Medication features
medications AS (
  SELECT 
    p.subject_id,
    p.hadm_id,
    COUNT(DISTINCT p.drug) as num_medications,
    CASE WHEN COUNT(DISTINCT p.drug) > 5 THEN 1 ELSE 0 END as polypharmacy_flag,
    MAX(CASE WHEN LOWER(p.drug) LIKE '%warfarin%' OR LOWER(p.drug) LIKE '%heparin%' THEN 1 ELSE 0 END) as anticoagulant_flag,
    MAX(CASE WHEN LOWER(p.drug) LIKE '%insulin%' THEN 1 ELSE 0 END) as insulin_flag,
    MAX(CASE WHEN LOWER(p.drug) LIKE '%opioid%' OR LOWER(p.drug) LIKE '%morphine%' OR LOWER(p.drug) LIKE '%fentanyl%' THEN 1 ELSE 0 END) as opioid_flag,
    MAX(CASE WHEN LOWER(p.drug) LIKE '%antibiotic%' OR LOWER(p.drug) LIKE '%cefazolin%' OR LOWER(p.drug) LIKE '%vancomycin%' THEN 1 ELSE 0 END) as antibiotic_flag
  FROM `physionet-data.mimiciv_3_1_hosp.prescriptions` p
  WHERE p.hadm_id IN (SELECT hadm_id FROM cohort)
  GROUP BY p.subject_id, p.hadm_id
),

-- Historical admission features
historical AS (
  SELECT 
    curr.subject_id,
    curr.hadm_id,
    COUNT(DISTINCT CASE WHEN prior.dischtime < curr.admittime AND DATETIME_DIFF(curr.admittime, prior.dischtime, DAY) <= 30 THEN prior.hadm_id END) as num_admissions_last_30d,
    COUNT(DISTINCT CASE WHEN prior.dischtime < curr.admittime AND DATETIME_DIFF(curr.admittime, prior.dischtime, DAY) <= 90 THEN prior.hadm_id END) as num_admissions_last_90d,
    COUNT(DISTINCT CASE WHEN prior.dischtime < curr.admittime AND DATETIME_DIFF(curr.admittime, prior.dischtime, DAY) <= 365 THEN prior.hadm_id END) as num_admissions_last_year,
    MIN(CASE WHEN prior.dischtime < curr.admittime THEN DATETIME_DIFF(curr.admittime, prior.dischtime, DAY) END) as days_since_last_discharge,
    COUNT(DISTINCT CASE WHEN prior.dischtime < curr.admittime THEN prior.hadm_id END) as total_prior_admissions,
    CASE WHEN COUNT(DISTINCT CASE WHEN prior.dischtime < curr.admittime AND DATETIME_DIFF(curr.admittime, prior.dischtime, DAY) <= 30 THEN prior.hadm_id END) > 0 THEN 1 ELSE 0 END as recent_admission_flag,
    CASE WHEN COUNT(DISTINCT CASE WHEN prior.dischtime < curr.admittime THEN prior.hadm_id END) >= 3 THEN 1 ELSE 0 END as frequent_flyer_flag
  FROM cohort curr
  LEFT JOIN `physionet-data.mimiciv_3_1_hosp.admissions` prior
    ON curr.subject_id = prior.subject_id
    AND prior.hospital_expire_flag = 0
  GROUP BY curr.subject_id, curr.hadm_id, curr.admittime
),

-- Target variable (readmission)
target AS (
  SELECT 
    curr.subject_id,
    curr.hadm_id,
    DATETIME_DIFF(LEAD(curr.admittime) OVER (PARTITION BY curr.subject_id ORDER BY curr.admittime), curr.dischtime, DAY) as days_to_next_admission,
    CASE WHEN DATETIME_DIFF(LEAD(curr.admittime) OVER (PARTITION BY curr.subject_id ORDER BY curr.admittime), curr.dischtime, DAY) IS NOT NULL 
         AND DATETIME_DIFF(LEAD(curr.admittime) OVER (PARTITION BY curr.subject_id ORDER BY curr.admittime), curr.dischtime, DAY) <= 30 THEN 1 ELSE 0 END as readmitted_30d,
    CASE WHEN DATETIME_DIFF(LEAD(curr.admittime) OVER (PARTITION BY curr.subject_id ORDER BY curr.admittime), curr.dischtime, DAY) IS NOT NULL 
         AND DATETIME_DIFF(LEAD(curr.admittime) OVER (PARTITION BY curr.subject_id ORDER BY curr.admittime), curr.dischtime, DAY) <= 60 THEN 1 ELSE 0 END as readmitted_60d,
    CASE WHEN DATETIME_DIFF(LEAD(curr.admittime) OVER (PARTITION BY curr.subject_id ORDER BY curr.admittime), curr.dischtime, DAY) IS NOT NULL 
         AND DATETIME_DIFF(LEAD(curr.admittime) OVER (PARTITION BY curr.subject_id ORDER BY curr.admittime), curr.dischtime, DAY) <= 90 THEN 1 ELSE 0 END as readmitted_90d
  FROM cohort curr
)

-- Final merged dataset
SELECT 
  c.subject_id,
  c.hadm_id,
  c.admittime,
  c.dischtime,
  
  -- Demographics
  d.gender,
  d.age,
  d.race,
  d.marital_status,
  d.language,
  d.insurance,
  d.admission_type,
  d.admission_location,
  d.discharge_location,
  d.los_hours,
  d.los_days,
  
  -- Comorbidities
  COALESCE(co.num_diagnoses, 0) as num_diagnoses,
  COALESCE(co.cci_mi, 0) as cci_mi,
  COALESCE(co.cci_chf, 0) as cci_chf,
  COALESCE(co.cci_pvd, 0) as cci_pvd,
  COALESCE(co.cci_cvd, 0) as cci_cvd,
  COALESCE(co.cci_dementia, 0) as cci_dementia,
  COALESCE(co.cci_copd, 0) as cci_copd,
  COALESCE(co.cci_diabetes, 0) as cci_diabetes,
  COALESCE(co.cci_ckd, 0) as cci_ckd,
  COALESCE(co.cci_cancer, 0) as cci_cancer,
  
  -- Labs
  l.num_lab_tests_24h,
  l.num_abnormal_labs,
  l.hemoglobin_min,
  l.wbc_max,
  l.creatinine_max,
  l.sodium_min,
  l.sodium_max,
  l.potassium_min,
  l.potassium_max,
  l.glucose_min,
  l.glucose_max,
  
  -- Medications
  COALESCE(m.num_medications, 0) as num_medications,
  COALESCE(m.polypharmacy_flag, 0) as polypharmacy_flag,
  COALESCE(m.anticoagulant_flag, 0) as anticoagulant_flag,
  COALESCE(m.insulin_flag, 0) as insulin_flag,
  COALESCE(m.opioid_flag, 0) as opioid_flag,
  COALESCE(m.antibiotic_flag, 0) as antibiotic_flag,
  
  -- Historical
  COALESCE(h.num_admissions_last_30d, 0) as num_admissions_last_30d,
  COALESCE(h.num_admissions_last_90d, 0) as num_admissions_last_90d,
  COALESCE(h.num_admissions_last_year, 0) as num_admissions_last_year,
  h.days_since_last_discharge,
  COALESCE(h.total_prior_admissions, 0) as total_prior_admissions,
  COALESCE(h.recent_admission_flag, 0) as recent_admission_flag,
  COALESCE(h.frequent_flyer_flag, 0) as frequent_flyer_flag,
  
  -- Target variable
  t.days_to_next_admission,
  COALESCE(t.readmitted_30d, 0) as readmitted_30d,
  COALESCE(t.readmitted_60d, 0) as readmitted_60d,
  COALESCE(t.readmitted_90d, 0) as readmitted_90d

FROM cohort c
LEFT JOIN demographics d ON c.hadm_id = d.hadm_id
LEFT JOIN comorbidities co ON c.hadm_id = co.hadm_id
LEFT JOIN labs l ON c.hadm_id = l.hadm_id
LEFT JOIN medications m ON c.hadm_id = m.hadm_id
LEFT JOIN historical h ON c.hadm_id = h.hadm_id
LEFT JOIN target t ON c.hadm_id = t.hadm_id
ORDER BY c.subject_id, c.admittime
;