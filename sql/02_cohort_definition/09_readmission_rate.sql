-- Calculate 30-day readmissions
WITH ranked_admissions AS (
  SELECT 
    subject_id,
    hadm_id,
    admittime,
    dischtime,
    hospital_expire_flag,
    admission_type,
    -- Get the next admission time for the same patient
    LEAD(admittime) OVER (PARTITION BY subject_id ORDER BY admittime) as next_admittime,
    -- Calculate days between discharge and next admission
    DATETIME_DIFF(
      LEAD(admittime) OVER (PARTITION BY subject_id ORDER BY admittime),
      dischtime,
      DAY
    ) as days_to_next_admission
  FROM `physionet-data.mimiciv_3_1_hosp.admissions`
  WHERE dischtime IS NOT NULL
)
SELECT 
  COUNT(*) as total_discharges,
  SUM(CASE WHEN days_to_next_admission IS NOT NULL AND days_to_next_admission <= 30 THEN 1 ELSE 0 END) as readmissions_30d,
  ROUND(100.0 * SUM(CASE WHEN days_to_next_admission IS NOT NULL AND days_to_next_admission <= 30 THEN 1 ELSE 0 END) / COUNT(*), 2) as readmission_rate_30d
FROM ranked_admissions
WHERE hospital_expire_flag = 0;  -- Exclude deaths