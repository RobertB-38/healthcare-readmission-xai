-- ============================================================================
-- TEST BIGQUERY ACCESS TO MIMIC-IV
-- ============================================================================
-- Purpose: Verify access to MIMIC-IV dataset
-- Author: Robert Borkar
-- Date: 2024-11-13
-- ============================================================================

SELECT COUNT(*) as total_patients
   FROM `physionet-data.mimiciv_3_1_hosp.patients`;

SELECT COUNT(*) as total_admissions
    FROM `physionet-data.mimiciv_3_1_hosp.admissions`;

SELECT 
  subject_id,
  gender,
  anchor_age,
  anchor_year_group
FROM `physionet-data.mimiciv_3_1_hosp.patients`
LIMIT 10;


