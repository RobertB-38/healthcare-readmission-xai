-- ============================================================================
-- HISTORICAL FEATURES - PRIOR ADMISSION PATTERNS
-- ============================================================================
-- Purpose: Calculate historical admission patterns and readmission history

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

prior_admissions AS (
  SELECT 
    curr.subject_id,
    curr.hadm_id as current_hadm_id,
    curr.admittime as current_admittime,
    
    -- Count prior admissions in different time windows
    COUNT(DISTINCT CASE 
      WHEN prior.dischtime < curr.admittime 
      AND DATETIME_DIFF(curr.admittime, prior.dischtime, DAY) <= 30 
      THEN prior.hadm_id 
    END) as num_admissions_last_30d,
    
    COUNT(DISTINCT CASE 
      WHEN prior.dischtime < curr.admittime 
      AND DATETIME_DIFF(curr.admittime, prior.dischtime, DAY) <= 90 
      THEN prior.hadm_id 
    END) as num_admissions_last_90d,
    
    COUNT(DISTINCT CASE 
      WHEN prior.dischtime < curr.admittime 
      AND DATETIME_DIFF(curr.admittime, prior.dischtime, DAY) <= 365 
      THEN prior.hadm_id 
    END) as num_admissions_last_year,
    
    -- Days since last discharge
    MIN(CASE 
      WHEN prior.dischtime < curr.admittime 
      THEN DATETIME_DIFF(curr.admittime, prior.dischtime, DAY)
    END) as days_since_last_discharge,
    
    -- Total lifetime admissions (prior to current)
    COUNT(DISTINCT CASE 
      WHEN prior.dischtime < curr.admittime 
      THEN prior.hadm_id 
    END) as total_prior_admissions

  FROM cohort curr
  LEFT JOIN `physionet-data.mimiciv_3_1_hosp.admissions` prior
    ON curr.subject_id = prior.subject_id
    AND prior.hospital_expire_flag = 0  -- only count survived admissions
  GROUP BY curr.subject_id, curr.hadm_id, curr.admittime
)

SELECT 
  subject_id,
  current_hadm_id as hadm_id,
  COALESCE(num_admissions_last_30d, 0) as num_admissions_last_30d,
  COALESCE(num_admissions_last_90d, 0) as num_admissions_last_90d,
  COALESCE(num_admissions_last_year, 0) as num_admissions_last_year,
  days_since_last_discharge,
  COALESCE(total_prior_admissions, 0) as total_prior_admissions,
  
  -- High-risk flags
  CASE WHEN COALESCE(num_admissions_last_30d, 0) > 0 THEN 1 ELSE 0 END as recent_admission_flag,
  CASE WHEN COALESCE(total_prior_admissions, 0) >= 3 THEN 1 ELSE 0 END as frequent_flyer_flag

FROM prior_admissions
ORDER BY subject_id, current_admittime
LIMIT 1000;