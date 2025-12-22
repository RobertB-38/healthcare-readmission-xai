-- ============================================================================
-- MEDICATION FEATURES - POLYPHARMACY AND HIGH-RISK MEDICATIONS
-- ============================================================================
-- Purpose: Extract medication counts and high-risk drug classes

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
)

SELECT 
  p.subject_id,
  p.hadm_id,
  
  -- Total unique medications
  COUNT(DISTINCT p.drug) as num_medications,
  
  -- Polypharmacy flag (>5 medications = high risk)
  CASE WHEN COUNT(DISTINCT p.drug) > 5 THEN 1 ELSE 0 END as polypharmacy_flag,
  
  -- High-risk medication classes (based on drug names - simplified)
  MAX(CASE WHEN LOWER(p.drug) LIKE '%warfarin%' OR LOWER(p.drug) LIKE '%heparin%' THEN 1 ELSE 0 END) as anticoagulant_flag,
  MAX(CASE WHEN LOWER(p.drug) LIKE '%insulin%' THEN 1 ELSE 0 END) as insulin_flag,
  MAX(CASE WHEN LOWER(p.drug) LIKE '%opioid%' OR LOWER(p.drug) LIKE '%morphine%' OR LOWER(p.drug) LIKE '%fentanyl%' THEN 1 ELSE 0 END) as opioid_flag,
  MAX(CASE WHEN LOWER(p.drug) LIKE '%antibiotic%' OR LOWER(p.drug) LIKE '%cefazolin%' OR LOWER(p.drug) LIKE '%vancomycin%' THEN 1 ELSE 0 END) as antibiotic_flag

FROM `physionet-data.mimiciv_3_1_hosp.prescriptions` p
INNER JOIN cohort c
  ON p.hadm_id = c.hadm_id
GROUP BY p.subject_id, p.hadm_id
LIMIT 1000;