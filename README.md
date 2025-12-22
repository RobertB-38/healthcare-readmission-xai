# Healthcare Readmission Risk Prediction Using Explainable AI

**MSc Computing (Data Analytics) - DCU - 2025-26**  
**Author:** Robert Borkar  
**Collaborator:** Niket  
**Supervisor:** Dr. Mohammed Amine Togou

## Project Overview

Predicting hospital readmissions (30/60/90 days) using machine learning with explainable AI techniques (SHAP, LIME) to provide clinical interpretability.

**Dataset:** MIMIC-IV v3.1 (364,627 patients, 431,231 admissions)  
**Target:** AUROC ≥ 0.75 with clinically meaningful explanations

## Research Questions

**RQ1: Prediction Performance**
Can we predict 30-day hospital readmission using ensemble methods (Random Forest, XGBoost) with AUROC >0.80?

**RQ2: Neural Network Comparison**
Do LSTM neural networks with attention mechanisms improve prediction accuracy over traditional ML approaches?

**RQ3: Feature Importance**
Which clinical features (demographics, comorbidities, lab values, medications, historical admission patterns) are most predictive of readmission using SHAP and LIME explainability methods?

**RQ4: Clinical Validation**
Can SHAP/LIME identified risk factors be validated against existing clinical literature on readmission predictors?

**RQ5: Model Interpretability**
Can neural networks be made explainable using SHAP/LIME, proving they are not "black boxes"?

**Secondary Question**: Can we also predict length of stay as an alternative utilitarian metric?

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

---

## Patient Tracking Across Admissions

MIMIC-IV enables longitudinal patient tracking through:
- `subject_id`: Unique patient identifier (preserved across all admissions)
- `hadm_id`: Unique hospital admission identifier
- Dates shifted 100+ years for anonymization BUT temporal ordering preserved
- Historical features calculated using `subject_id` to track same patient across multiple visits
- Implemented in Query 6 (`06_historical_features.sql`)

This allows us to:
- Calculate prior admission counts (30/60/365 day windows)
- Identify "frequent flyer" patients (3+ prior admissions)
- Measure days since last discharge

---

## Modeling Strategy (Per Supervisor Feedback)

### Phase 1: Baseline ML Models
1. Logistic Regression (interpretable baseline)
2. XGBoost (state-of-the-art ensemble method)
3. Class imbalance handling (SMOTE, cost-sensitive learning)
4. SHAP explainability analysis

### Phase 2: Neural Networks
1. LSTM with attention mechanisms
2. Compare performance to baseline models
3. SHAP explainability to prove interpretability (NOT a black box)

### Phase 3: Comparative Analysis
1. Model performance comparison (AUROC, AUPRC, sensitivity, specificity)
2. Feature importance comparison across models
3. Interpretability analysis (SHAP global + LIME local)
4. Clinical validation against literature
5. t-SNE visualization of patient clusters

### Primary Target: 30-day readmission prediction
### Secondary Analysis: Length of stay prediction (if time permits)

---

## Contact

1. Robert Borkar - robert.borkar2@mail.dcu.ie
2. Niket Ahire - niketsuresh.ahire2@mail.dcu.ie

