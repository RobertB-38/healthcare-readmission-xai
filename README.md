# Healthcare Readmission Risk Prediction Using Explainable AI

**MSc Computing (Data Analytics) - DCU - 2025-26**  
**Author:** Robert Borkar  
**Collaborator:** Niket  
**Supervisor:** Dr. Mohammed Amine Togou

## Project Overview

Predicting hospital readmissions (30/60/90 days) using machine learning with explainable AI techniques (SHAP, LIME) to provide clinical interpretability.

**Dataset:** MIMIC-IV v3.1 (364,627 patients, 431,231 admissions)  
**Target:** AUROC ≥ 0.75 with clinically meaningful explanations

## Project Structure
```
├── sql/                          # BigQuery SQL queries
│   ├── 01_data_exploration/      # Initial dataset analysis
│   ├── 02_cohort_definition/     # Inclusion/exclusion criteria
│   ├── 03_feature_engineering/   # Feature extraction queries
│   └── 04_model_queries/         # Final dataset generation
├── notebooks/                    # Jupyter notebooks for analysis
├── src/                          # Python source code
├── models/                       # Trained model artifacts
├── results/                      # Figures, tables, performance metrics
└── docs/                         # Documentation and reports
```

## Current Status

- [x] CITI Training & MIMIC-IV Access
- [x] Initial Data Exploration
- [x] Cohort Definition (406,031 admissions, 17.43% readmission rate)
- [x] Panel Presentation Approval
- [ ] Feature Engineering
- [ ] Model Development
- [ ] Explainability Analysis

## Quick Start
```bash
# Clone repository
git clone https://gitlab.computing.dcu.ie/robert.borkar2/hospital-re-admission.git

# Install dependencies
pip install -r requirements.txt
```

## Key Metrics (Cohort Definition)

- **Total admissions:** 406,031
- **30-day readmissions:** 70,791
- **Readmission rate:** 17.43%
- **Exclusions:** Deaths, pediatric (<18), short stays (<24h), elective admissions

---

## Phase 2: Feature Engineering ✅ COMPLETED

**Status**: Complete  
**Completion Date**: December 22, 2024

### Features Extracted (6 Categories, ~50 Features)

1. **Demographics (13 features)**
   - Age, gender, race, marital status, language
   - Insurance type, admission type/location
   - Length of stay (hours, days)

2. **Comorbidities (10 features)**
   - Total diagnosis count
   - Charlson Comorbidity Index: MI, CHF, PVD, CVD, Dementia, COPD, Diabetes, CKD, Cancer

3. **Lab Values (13 features)**
   - Total lab tests and abnormal count (first 24h)
   - Critical values: hemoglobin, WBC, creatinine, sodium, potassium, glucose

4. **Medications (6 features)**
   - Total medication count, polypharmacy flag
   - High-risk flags: anticoagulants, insulin, opioids, antibiotics

5. **Historical Admissions (7 features)**
   - Prior admissions (30/90/365 day windows)
   - Days since last discharge, total lifetime admissions
   - Recent admission flag, frequent flyer flag

6. **Target Variables (4 features)**
   - Days to next admission
   - Readmission flags: 30/60/90 day windows

### Final Dataset
- **Rows**: 406,031 hospital admissions
- **Features**: ~50 (demographics + clinical + target)
- **File**: `data/processed/mimic_readmission_final.csv`
- **30-day Readmission Rate**: 17.43%

### SQL Queries
Location: `sql/03_feature_engineering/`
1. `01_demographics_features.sql`
2. `02_comorbidity_features.sql`
3. `03_target_variable_readmission.sql`
4. `04_lab_values_features.sql`
5. `05_medication_features.sql`
6. `06_historical_features.sql`
7. `07_final_merged_dataset.sql` (master merge)

### Key Findings
- **Polypharmacy is universal**: 98% of patients on >5 medications
- **Historical patterns strongest predictor**: Patients with prior 30-day admissions have extreme readmission risk
- **Frequent flyers identified**: Some patients with 6+ consecutive readmissions
- **Lab abnormalities vary widely**: 0-150+ abnormal tests in first 24 hours

---

## Phase 3: Model Development 🚧 IN PROGRESS

**Next Steps**:
1. Python environment setup & EDA
2. Data preprocessing (missing values, encoding, scaling)
3. Temporal train/validation/test splits
4. Baseline models (Random Forest, XGBoost)
5. Neural networks with attention mechanisms
6. Class imbalance handling (SMOTE variants, cost-sensitive learning)
7. Explainability analysis (SHAP, LIME)
8. Clinical validation of model insights


## Contact

1. Robert Borkar - robert.borkar2@mail.dcu.ie
2. Niket Ahire - niketsuresh.ahire2@mail.dcu.ie

