# Healthcare Readmission Risk: Prediction and Trustworthy Explanations

Predicting 30/60/90-day hospital readmission on MIMIC-IV, and a framework for deciding which explanation of those predictions a clinician should actually trust.

**Author:** Robert Borkar
**Collaborator:** Niket Ahire
**Supervisor:** Prof Martin Crane (DCU). Supervision continues with Prof Mark Roantree from June 2026.
**Context:** MSc Computing (Data Analytics), DCU, 2025-26

> Note: raw data files are not stored here (MIMIC-IV data use agreement). Access MIMIC-IV v3.1 at https://physionet.org/content/mimiciv/. The pipeline regenerates everything from the source extract.

---

## What this project is

Most readmission projects stop at "we trained a model and SHAP says feature X matters." The problem is that different explanation methods often disagree about feature X, and there is usually no way to tell which one to believe. This project tackles that directly.

We train readmission models on MIMIC-IV, then build a framework that scores each explanation on three things and uses them to pick the trustworthy one:

1. **Fidelity** - does the explanation actually reflect what the model does?
2. **Plausibility** - do the features it highlights match what clinical literature says drives readmission?
3. **Disagreement** - do the different methods (SHAP, LIME) even agree with each other?

When the methods disagree, fidelity and plausibility decide which explanation wins. We run the whole thing across three prediction windows (30, 60, 90 days) to check the answer is stable.

---

## The main result

Prediction performance sits at a data ceiling for a single-site extract, so the contribution is not the AUROC. It is the explanation framework and what it tells us.

| Window | Readmission rate | Test AUROC |
|--------|------------------|------------|
| 30 days | ~18% | ~0.72 |
| 60 days | ~25% | ~0.73 |
| 90 days | ~29% | ~0.74 |

AUROC around 0.72 on a single-site MIMIC-IV cohort is in line with what the data supports. Chasing a higher number on this extract is not the point. The interesting finding is in the explanations:

- The two SHAP variants (TreeSHAP, KernelSHAP) agree strongly, which confirms the pipeline is sound.
- SHAP and LIME disagree a lot. They often pick different top features, sometimes in opposite directions.
- On fidelity and clinical direction, SHAP scores roughly 0.75-0.88, LIME around 0.24-0.36.
- So for this model, SHAP gives the more trustworthy explanation, and that holds at every window.

In short: SHAP and LIME do not tell the same story here, and the framework gives a principled reason to trust SHAP over LIME.

---

## Methods and stack

- **Models:** XGBoost (final model), LightGBM, BiLSTM with Bahdanau attention, plus a fairness-constrained variant (FairGBM).
- **Explainability:** TreeSHAP, KernelSHAP, LIME, and Integrated Gradients (on the neural model).
- **Framework metrics:** faithfulness correlation and sparseness (fidelity), agreement against a literature-derived clinical reference set (plausibility), and Krishna et al.'s disagreement measures (cross-method).
- **Validation:** chronological train/validation/test split (train on the past, test on the future) with an explicit leakage guard. No random splits.
- **Fairness:** the final model keeps race as a feature; a with/without-race check showed near-identical AUROC (~0.70 either way), and FairGBM was added as a constrained variant.
- **Data:** MIMIC-IV v3.1 via BigQuery, 406,031 admissions after inclusion criteria (~180K patients), ~45 engineered features across demographics, comorbidities (Charlson), labs, medications, and prior-admission history.

---

## Project status

Where things stand as of June 2026.

| Phase | Work | Status |
|-------|------|--------|
| 1 | Data access and cohort definition | Done (Oct-Nov 2025) |
| 2 | Feature engineering (~45 features, 6 categories) | Done (Dec 2025) |
| 3 | Preprocessing and chronological split | Done (Jan 2026) |
| 4 | Models: LR, XGBoost, LightGBM, BiLSTM+attention, FairGBM | Done (Mar-May 2026) |
| 5 | Explainability and clinical validation framework (SHAP, LIME, IG, t-SNE) | Done (Jun 2026) |
| 6 | IEEE paper and viva | In progress (Jun-Aug 2026) |

### Recent milestones

- Caught and corrected train/test leakage. Moved to a strict chronological split with an integrity check, and dropped leakage columns. The headline AUROC went from 0.79 to an honest 0.72.
- Built the three-axis trust framework. Verdict: trust SHAP over LIME, stable across the 30, 60 and 90 day windows.
- Added Integrated Gradients on the BiLSTM as a cross-architecture check on the neural model.
- Built t-SNE patient maps in both feature space and SHAP space.
- Found that single-admission patients are structural non-readmissions (they can never be readmitted by construction). We report 0.72 on all patients and 0.68 on the two-plus-admission cohort as the honest robustness number.

---

## Project structure

```
sql/         BigQuery queries: cohort, feature engineering
notebooks/   data prep, models, SHAP/LIME, fairness, the validation framework, IG, t-SNE
src/         shared Python code
results/     figures, metric tables, the clinical reference set
docs/        notes and reports
```

Patient data, trained model files, and large caches are not committed (MIMIC licensing and size).

---

## Roadmap (where this is going next)

The thesis version ends at the validation framework. Beyond that, I am taking this further as a personal project toward a deployable system:

- Wrap the model and explanation framework behind an API.
- A retrieval layer (RAG) over clinical guidelines so each explanation comes with grounded, cited context.
- A small LLM agent that turns a patient's risk explanation into a readable clinician summary.
- Cloud deployment with monitoring and drift checks.
- Extend beyond readmission to length-of-stay as a second outcome.

---

## Contact

- Robert Borkar - robert.borkar2@mail.dcu.ie
- Niket Ahire - niketsuresh.ahire2@mail.dcu.ie
