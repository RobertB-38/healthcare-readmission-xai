# Healthcare Readmission Risk Prediction Using Explainable AI

**MSc Computing (Data Analytics) - DCU - 2025-26**  
**Author:** Robert Borkar  
**Collaborator:** Niket Ahire  
**Supervisor:** Prof Martin Crane

## Project Overview

Predicting 30-day hospital readmissions using machine learning with explainable AI techniques (SHAP, LIME) to provide clinical interpretability. The core contribution is a clinical validation framework that systematically validates whether SHAP/LIME explanations align with established medical literature.

**Dataset:** MIMIC-IV v3.1 via Google BigQuery (406,031 admissions, 17.43% 30-day readmission rate)  
**Target:** AUROC ≥ 0.75 with clinically validated explanations

> Note: Raw data files are not stored in this repository (MIMIC-IV data use agreement). Access MIMIC-IV v3.1 at https://physionet.org/content/mimiciv/

---

## Research Questions

**RQ1:** How do SHAP and LIME explanations compare across Logistic Regression, XGBoost, and LSTM models for readmission prediction?

**RQ2:** Can a clinical validation framework systematically verify that XAI outputs align with established medical literature on readmission risk factors?

**RQ3:** How does class imbalance handling affect the stability and reliability of SHAP/LIME explanations?

**RQ4:** Can t-SNE visualisations integrated with SHAP feature importance reveal clinically meaningful patient risk clusters?

---

## Current Model Results

| Model | Test AUROC |
|---|---|
| Logistic Regression (baseline) | 0.7021 |
| LR + Class Weights | 0.7025 |
| LR + SMOTE | 0.6984 |
| XGBoost (tuned, 30-iter RandomizedSearchCV) | 0.7197 |
| LSTM + Bahdanau Attention (initial) | 0.6951 |
| **Target** | **0.7500** |

---

## Project Structure

```
├── sql/                          # BigQuery SQL queries
│   ├── 01_data_exploration/      # Initial dataset analysis
│   ├── 02_cohort_definition/     # Inclusion/exclusion criteria
│   └── 03_feature_engineering/   # Feature extraction queries
├── notebooks/                    # Jupyter/Colab notebooks
│   ├── 01_data_loading_and_split.ipynb
│   ├── 02_exploratory_analysis.ipynb
│   ├── 03_baseline_models.ipynb
│   ├── 04_xgboost_tuning.ipynb
│   └── 05_lstm_attention.ipynb
├── Literature Review/            # Submitted literature review (IEEE format)
├── models/                       # Trained model artifacts (local only, not in repo)
├── results/                      # Figures, tables, performance metrics
└── docs/                         # Documentation and reports
```

---

## Project Timeline

### Phase 1: Data Access & Exploration ✅
**Completed:** October-November 2025

- MIMIC-IV v3.1 access via PhysioNet/BigQuery
- Cohort definition: 406,031 admissions meeting inclusion criteria
- Readmission rate validated: 17.43% (30-day)
- Panel presentation completed and approved

**Key decisions:**
- Exclusion: deaths during admission, paediatric (<18), stays <24h
- Temporal validation approach confirmed from the start

---

### Phase 2: Feature Engineering ✅
**Completed:** December 2025

50 features across 6 categories: demographics, comorbidities (Charlson Index), lab values, medications, historical admission patterns, target variables.

**Key finding:** Prior admission counts are the strongest readmission predictor — consistent with LACE index (van Walraven et al., 2010, CMAJ).

SQL queries: `sql/03_feature_engineering/` (01-07)

---

### Phase 3: Data Preprocessing & Validation ✅
**Completed:** January 2026

- Missing value imputation: median for labs, 0 for historical features, UNKNOWN for categoricals
- Temporal train/test split (80/20, split date 2179-02-08)
- Zero missing values, no target leakage confirmed
- Train: 324,824 admissions | Test: 81,207 admissions

---

### Phase 4: Model Development ✅
**Completed:** March 2026

**Baseline Models** (`03_baseline_models.ipynb`, `04_xgboost_tuning.ipynb`):
- Logistic Regression with three imbalance strategies (none, class weights, SMOTE)
- XGBoost with 30-iteration RandomizedSearchCV hyperparameter tuning
- Best baseline: XGBoost 0.7197 AUROC

**LSTM + Attention** (`05_lstm_attention.ipynb`):
- Bidirectional LSTM with Bahdanau attention mechanism
- Full cohort with pre-padding for single-admission patients (no selection bias)
- Chronological 70/15/15 train/val/test split — consistent with baseline methodology
- Class weighting (4.69x) for imbalance handling
- Early stopping and ReduceLROnPlateau callbacks
- Initial test AUROC: 0.6951 — tuning in progress

**Key architectural decisions:**
- Race excluded as feature (production deployment ethics and clinical fairness)
- Per-admission labelling to avoid data leakage
- Sequence length capped at 10 (covers 95%+ of patients efficiently)

---

### Phase 5: Explainability & Clinical Validation 🔄
**Target:** May 2026

- SHAP global feature importance across all three model types (RQ1)
- LIME local patient-level explanations
- Clinical validation framework — validating explanations against LACE index, HOSPITAL score, comorbidity literature (RQ2)
- Class imbalance effects on explanation stability (RQ3)
- t-SNE patient clustering integrated with SHAP (RQ4)

---

### Phase 6: Thesis Writing & Submission 🔄
**Target:** May-July 2026

---

## Literature Review

Submitted February 2026. IEEE double-column format, 3 pages, 11 references.  
Available in `Literature Review/` directory.

---

## Contact

- Robert Borkar — robert.borkar2@mail.dcu.ie
- Niket Ahire — niketsuresh.ahire2@mail.dcu.ie