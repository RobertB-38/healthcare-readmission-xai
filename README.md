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

## Contact

Robert Borkar - robert.borkar2@mail.dcu.ie
Niket Ahire - niketsuresh.ahire2@mail.dcu.ie
