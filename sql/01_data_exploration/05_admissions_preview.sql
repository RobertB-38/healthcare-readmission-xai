-- Preview admissions table
SELECT 
  subject_id,
  hadm_id,
  admittime,
  dischtime,
  admission_type,
  admission_location,
  discharge_location,
  insurance,
  hospital_expire_flag
FROM `physionet-data.mimiciv_3_1_hosp.admissions`
LIMIT 10;