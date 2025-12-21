-- What years does this data cover?
SELECT 
  MIN(admittime) as earliest_admission,
  MAX(admittime) as latest_admission,
  DATETIME_DIFF(MAX(admittime), MIN(admittime), YEAR) as years_of_data
FROM `physionet-data.mimiciv_3_1_hosp.admissions`;