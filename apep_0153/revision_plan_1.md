# Revision Plan - Round 1

## Reviewer Summary

| Reviewer | Decision | Key Concerns |
|----------|----------|-------------|
| GPT-5-mini | Major Revision | Thin controls, attenuation quantification, leave-one-out, CIs in tables |
| Grok-4.1-Fast | Minor Revision | Add 3 references, synthetic control consideration |
| Gemini-3-Flash | Minor Revision | MDE analysis, alternative control group, outcome refinement |

## Grouped Concerns and Actions

### 1. Thin Control Group / Inference (All 3 reviewers)
**Action:** Add leave-one-out analysis dropping each control state, report in robustness table. Note: synthetic control not feasible with 4 controls (need pre-treatment donor pool).

### 2. MDE / Power (Gemini)
**Action:** Add MDE calculation based on sample size, clustering, and residual variance. Report in text.

### 3. Confidence Intervals in Tables (GPT)
**Action:** Add 95% CI row to Table 2 main results.

### 4. Missing References (All 3)
**Action:** Add Ibragimov & Muller (2010), Herd & Moynihan (2018) for admin burden, and relevant unwinding references.

### 5. Attenuation Bounding (GPT)
**Action:** Add paragraph estimating attenuation under uniform birth-month distribution.

### 6. Negative Post-PHE ATT Diagnosis (GPT)
**Action:** Already discussed in Discussion; strengthen with more specific reference to unwinding dynamics.

### Changes NOT Made (with justification)
- Administrative data merge: Not feasible without restricted data access
- Synthetic control: 4 control states insufficient for donor pool
- Birth month data: Not available in public ACS PUMS
- Alternative outcomes (spending, delayed care): Not available in ACS PUMS with postpartum identifier
